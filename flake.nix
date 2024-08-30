{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs.lib) optional optionals;

        beamBuilder = pkgs.beam.packagesWith (pkgs.beam.interpreters.erlang_27.override {
          version = "27.0.1";
          sha256 = "sha256-Lp6J9eq6RXDi0RRjeVO/CIa4h/m7/fwOp/y0u0sTdFQ=";
        });

        elixir = beamBuilder.elixir.override {
          version = "1.17.2";
          sha256 = "sha256-8rb2f4CvJzio3QgoxvCv1iz8HooXze0tWUJ4Sc13dxg=";
        };
      in
      with pkgs;
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            nodejs_22
            nodePackages.typescript-language-server
            nodePackages.prettier
            elixir
            (lexical.override { elixir = elixir; })
            postgresql_14
            glibcLocales
          ] ++ optional stdenv.isLinux inotify-tools
          ++ optional stdenv.isDarwin terminal-notifier
          ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
            CoreFoundation
            CoreServices
          ]);
        };
      });
}
