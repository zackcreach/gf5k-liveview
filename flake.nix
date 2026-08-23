{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    heroicons = {
      url = "github:tailwindlabs/heroicons/v2.1.1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      deploy-rs,
      heroicons,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        beamPackages =
          let
            overrideElixir = _final: previous: {
              elixir = previous.elixir_1_19;
            };
          in
          if pkgs.beamMinimal27Packages ? overrideScope then
            pkgs.beamMinimal27Packages.overrideScope overrideElixir
          else
            pkgs.beamMinimal27Packages.extend overrideElixir;
        version = "0.1.0";
        source = pkgs.lib.cleanSourceWith {
          src = ./.;
          filter = path: _type: !builtins.elem (baseNameOf path) [
            ".direnv"
            ".git"
            "_build"
            "deps"
          ];
        };
        mixNixDeps = import ./deps.nix {
          inherit (pkgs) lib;
          inherit beamPackages;
        };
        updateMixDeps = pkgs.writeShellApplication {
          name = "update-mix-deps";
          runtimeInputs = [ pkgs.mix2nix ];
          text = ''
            mix2nix mix.lock | sed -e '$d' > deps.nix
          '';
        };
        dependencyFreshness =
          pkgs.runCommand "gifmaster-mix-dependencies-fresh"
            {
              nativeBuildInputs = [ pkgs.mix2nix ];
            }
            ''
              mix2nix ${./mix.lock} | sed -e '$d' > generated-deps.nix
              if ! cmp --silent generated-deps.nix ${./deps.nix}; then
                echo "deps.nix is stale. Run: nix run .#update-mix-deps" >&2
                diff --unified ${./deps.nix} generated-deps.nix >&2 || true
                exit 1
              fi
              touch $out
            '';
      in
      {
        packages.default = beamPackages.mixRelease {
          pname = "gifmaster";
          inherit version mixNixDeps;
          src = source;
          nativeBuildInputs = [ dependencyFreshness ];
          HEROICONS_PATH = "${heroicons}/optimized";
          MIX_ESBUILD_PATH = "${pkgs.esbuild}/bin/esbuild";
          MIX_TAILWIND_PATH = "${pkgs.tailwindcss}/bin/tailwindcss";
          postBuild = ''
            mix do deps.loadpaths --no-deps-check + tailwind gifmaster --minify + esbuild gifmaster --minify + phx.digest
          '';
          postInstall = ''
            mkdir -p $out/share/prominent-tools
            printf '%s\n' '${
              self.rev or self.dirtyRev or "0000000000000000000000000000000000000000"
            }' > $out/share/prominent-tools/revision
          '';
        };

        packages.deploy-rs = deploy-rs.packages.${system}.default;
        packages.dependency-freshness = dependencyFreshness;

        apps.update-mix-deps = {
          type = "app";
          program = "${updateMixDeps}/bin/update-mix-deps";
        };

        checks.dependency-freshness = dependencyFreshness;

        devShells.default = pkgs.mkShell {
          packages = [
            beamPackages.elixir
            pkgs.esbuild
            pkgs.mix2nix
            pkgs.nodejs_22
            pkgs.postgresql_18
            pkgs.tailwindcss
          ];
          MIX_ESBUILD_PATH = "${pkgs.esbuild}/bin/esbuild";
          MIX_TAILWIND_PATH = "${pkgs.tailwindcss}/bin/tailwindcss";
          HEROICONS_PATH = "${heroicons}/optimized";
        };

        devShell = self.devShells.${system}.default;
      }
    )
    // {
      deploy.nodes.symphony = {
        hostname = "127.0.0.1";
        sshUser = "prominent-deploy";
        sshOpts = [
          "-o"
          "StrictHostKeyChecking=accept-new"
          "-o"
          "IdentitiesOnly=yes"
          "-i"
          "/var/lib/prominent-deploy/.ssh/prominent-deploy"
        ];
        remoteBuild = false;
        profiles.gifmaster = {
          user = "prominent-deploy";
          profilePath = "/nix/var/nix/profiles/per-user/prominent-deploy/gifmaster";
          path = deploy-rs.lib.x86_64-linux.activate.custom self.packages.x86_64-linux.default "sudo /run/current-system/sw/bin/prominent-tools-activate gifmaster";
        };
      };

      checks.x86_64-linux = deploy-rs.lib.x86_64-linux.deployChecks self.deploy // {
        dependency-freshness = self.packages.x86_64-linux.dependency-freshness;
      };
    };
}
