{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    bandit = buildMix rec {
      name = "bandit";
      version = "1.6.0";

      src = fetchHex {
        pkg = "bandit";
        version = "${version}";
        sha256 = "fd2491e564a7c5e11ff8496ebf530c342c742452c59de17ac0fb1f814a0ab01a";
      };

      beamDeps = [ hpax plug telemetry thousand_island websock ];
    };

    bcrypt_elixir = buildMix rec {
      name = "bcrypt_elixir";
      version = "3.2.0";

      src = fetchHex {
        pkg = "bcrypt_elixir";
        version = "${version}";
        sha256 = "563e92a6c77d667b19c5f4ba17ab6d440a085696bdf4c68b9b0f5b30bc5422b8";
      };

      beamDeps = [ comeonin elixir_make ];
    };

    castore = buildMix rec {
      name = "castore";
      version = "1.0.10";

      src = fetchHex {
        pkg = "castore";
        version = "${version}";
        sha256 = "1b0b7ea14d889d9ea21202c43a4fa015eb913021cb535e8ed91946f4b77a8848";
      };

      beamDeps = [];
    };

    comeonin = buildMix rec {
      name = "comeonin";
      version = "5.5.0";

      src = fetchHex {
        pkg = "comeonin";
        version = "${version}";
        sha256 = "6287fc3ba0aad34883cbe3f7949fc1d1e738e5ccdce77165bc99490aa69f47fb";
      };

      beamDeps = [];
    };

    db_connection = buildMix rec {
      name = "db_connection";
      version = "2.7.0";

      src = fetchHex {
        pkg = "db_connection";
        version = "${version}";
        sha256 = "dcf08f31b2701f857dfc787fbad78223d61a32204f217f15e881dd93e4bdd3ff";
      };

      beamDeps = [ telemetry ];
    };

    decimal = buildMix rec {
      name = "decimal";
      version = "2.2.0";

      src = fetchHex {
        pkg = "decimal";
        version = "${version}";
        sha256 = "af8daf87384b51b7e611fb1a1f2c4d4876b65ef968fa8bd3adf44cff401c7f21";
      };

      beamDeps = [];
    };

    dns_cluster = buildMix rec {
      name = "dns_cluster";
      version = "0.1.3";

      src = fetchHex {
        pkg = "dns_cluster";
        version = "${version}";
        sha256 = "46cb7c4a1b3e52c7ad4cbe33ca5079fbde4840dedeafca2baf77996c2da1bc33";
      };

      beamDeps = [];
    };

    ecto = buildMix rec {
      name = "ecto";
      version = "3.12.5";

      src = fetchHex {
        pkg = "ecto";
        version = "${version}";
        sha256 = "6eb18e80bef8bb57e17f5a7f068a1719fbda384d40fc37acb8eb8aeca493b6ea";
      };

      beamDeps = [ decimal jason telemetry ];
    };

    ecto_sql = buildMix rec {
      name = "ecto_sql";
      version = "3.12.1";

      src = fetchHex {
        pkg = "ecto_sql";
        version = "${version}";
        sha256 = "aff5b958a899762c5f09028c847569f7dfb9cc9d63bdb8133bff8a5546de6bf5";
      };

      beamDeps = [ db_connection ecto postgrex telemetry ];
    };

    elixir_make = buildMix rec {
      name = "elixir_make";
      version = "0.9.0";

      src = fetchHex {
        pkg = "elixir_make";
        version = "${version}";
        sha256 = "db23d4fd8b757462ad02f8aa73431a426fe6671c80b200d9710caf3d1dd0ffdb";
      };

      beamDeps = [];
    };

    esbuild = buildMix rec {
      name = "esbuild";
      version = "0.8.2";

      src = fetchHex {
        pkg = "esbuild";
        version = "${version}";
        sha256 = "558a8a08ed78eb820efbfda1de196569d8bfa9b51e8371a1934fbb31345feda7";
      };

      beamDeps = [ castore jason ];
    };

    expo = buildMix rec {
      name = "expo";
      version = "1.1.0";

      src = fetchHex {
        pkg = "expo";
        version = "${version}";
        sha256 = "fbadf93f4700fb44c331362177bdca9eeb8097e8b0ef525c9cc501cb9917c960";
      };

      beamDeps = [];
    };

    exsync = buildMix rec {
      name = "exsync";
      version = "0.4.1";

      src = fetchHex {
        pkg = "exsync";
        version = "${version}";
        sha256 = "cefb22aa805ec97ffc5b75a4e1dc54bcaf781e8b32564bf74abbe5803d1b5178";
      };

      beamDeps = [ file_system ];
    };

    file_system = buildMix rec {
      name = "file_system";
      version = "1.0.1";

      src = fetchHex {
        pkg = "file_system";
        version = "${version}";
        sha256 = "4414d1f38863ddf9120720cd976fce5bdde8e91d8283353f0e31850fa89feb9e";
      };

      beamDeps = [];
    };

    finch = buildMix rec {
      name = "finch";
      version = "0.19.0";

      src = fetchHex {
        pkg = "finch";
        version = "${version}";
        sha256 = "fc5324ce209125d1e2fa0fcd2634601c52a787aff1cd33ee833664a5af4ea2b6";
      };

      beamDeps = [ mime mint nimble_options nimble_pool telemetry ];
    };

    floki = buildMix rec {
      name = "floki";
      version = "0.36.3";

      src = fetchHex {
        pkg = "floki";
        version = "${version}";
        sha256 = "fe0158bff509e407735f6d40b3ee0d7deb47f3f3ee7c6c182ad28599f9f6b27a";
      };

      beamDeps = [];
    };

    gettext = buildMix rec {
      name = "gettext";
      version = "0.26.2";

      src = fetchHex {
        pkg = "gettext";
        version = "${version}";
        sha256 = "aa978504bcf76511efdc22d580ba08e2279caab1066b76bb9aa81c4a1e0a32a5";
      };

      beamDeps = [ expo ];
    };

    hpax = buildMix rec {
      name = "hpax";
      version = "1.0.0";

      src = fetchHex {
        pkg = "hpax";
        version = "${version}";
        sha256 = "7f1314731d711e2ca5fdc7fd361296593fc2542570b3105595bb0bc6d0fad601";
      };

      beamDeps = [];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.4.4";

      src = fetchHex {
        pkg = "jason";
        version = "${version}";
        sha256 = "c5eb0cab91f094599f94d55bc63409236a8ec69a21a67814529e8d5f6cc90b3b";
      };

      beamDeps = [ decimal ];
    };

    mime = buildMix rec {
      name = "mime";
      version = "2.0.6";

      src = fetchHex {
        pkg = "mime";
        version = "${version}";
        sha256 = "c9945363a6b26d747389aac3643f8e0e09d30499a138ad64fe8fd1d13d9b153e";
      };

      beamDeps = [];
    };

    mint = buildMix rec {
      name = "mint";
      version = "1.6.2";

      src = fetchHex {
        pkg = "mint";
        version = "${version}";
        sha256 = "5ee441dffc1892f1ae59127f74afe8fd82fda6587794278d924e4d90ea3d63f9";
      };

      beamDeps = [ castore hpax ];
    };

    nimble_options = buildMix rec {
      name = "nimble_options";
      version = "1.1.1";

      src = fetchHex {
        pkg = "nimble_options";
        version = "${version}";
        sha256 = "821b2470ca9442c4b6984882fe9bb0389371b8ddec4d45a9504f00a66f650b44";
      };

      beamDeps = [];
    };

    nimble_pool = buildMix rec {
      name = "nimble_pool";
      version = "1.1.0";

      src = fetchHex {
        pkg = "nimble_pool";
        version = "${version}";
        sha256 = "af2e4e6b34197db81f7aad230c1118eac993acc0dae6bc83bac0126d4ae0813a";
      };

      beamDeps = [];
    };

    phoenix = buildMix rec {
      name = "phoenix";
      version = "1.7.17";

      src = fetchHex {
        pkg = "phoenix";
        version = "${version}";
        sha256 = "50e8ad537f3f7b0efb1509b2f75b5c918f697be6a45d48e49a30d3b7c0e464c9";
      };

      beamDeps = [ castore jason phoenix_pubsub phoenix_template plug plug_crypto telemetry websock_adapter ];
    };

    phoenix_ecto = buildMix rec {
      name = "phoenix_ecto";
      version = "4.6.3";

      src = fetchHex {
        pkg = "phoenix_ecto";
        version = "${version}";
        sha256 = "909502956916a657a197f94cc1206d9a65247538de8a5e186f7537c895d95764";
      };

      beamDeps = [ ecto phoenix_html plug postgrex ];
    };

    phoenix_html = buildMix rec {
      name = "phoenix_html";
      version = "4.1.1";

      src = fetchHex {
        pkg = "phoenix_html";
        version = "${version}";
        sha256 = "f2f2df5a72bc9a2f510b21497fd7d2b86d932ec0598f0210fed4114adc546c6f";
      };

      beamDeps = [];
    };

    phoenix_live_dashboard = buildMix rec {
      name = "phoenix_live_dashboard";
      version = "0.8.5";

      src = fetchHex {
        pkg = "phoenix_live_dashboard";
        version = "${version}";
        sha256 = "1d73920515554d7d6c548aee0bf10a4780568b029d042eccb336db29ea0dad70";
      };

      beamDeps = [ ecto mime phoenix_live_view telemetry_metrics ];
    };

    phoenix_live_reload = buildMix rec {
      name = "phoenix_live_reload";
      version = "1.5.3";

      src = fetchHex {
        pkg = "phoenix_live_reload";
        version = "${version}";
        sha256 = "b4ec9cd73cb01ff1bd1cac92e045d13e7030330b74164297d1aee3907b54803c";
      };

      beamDeps = [ file_system phoenix ];
    };

    phoenix_live_view = buildMix rec {
      name = "phoenix_live_view";
      version = "1.0.0";

      src = fetchHex {
        pkg = "phoenix_live_view";
        version = "${version}";
        sha256 = "254caef0028765965ca6bd104cc7d68dcc7d57cc42912bef92f6b03047251d99";
      };

      beamDeps = [ floki jason phoenix phoenix_html phoenix_template plug telemetry ];
    };

    phoenix_pubsub = buildMix rec {
      name = "phoenix_pubsub";
      version = "2.1.3";

      src = fetchHex {
        pkg = "phoenix_pubsub";
        version = "${version}";
        sha256 = "bba06bc1dcfd8cb086759f0edc94a8ba2bc8896d5331a1e2c2902bf8e36ee502";
      };

      beamDeps = [];
    };

    phoenix_template = buildMix rec {
      name = "phoenix_template";
      version = "1.0.4";

      src = fetchHex {
        pkg = "phoenix_template";
        version = "${version}";
        sha256 = "2c0c81f0e5c6753faf5cca2f229c9709919aba34fab866d3bc05060c9c444206";
      };

      beamDeps = [ phoenix_html ];
    };

    plug = buildMix rec {
      name = "plug";
      version = "1.16.1";

      src = fetchHex {
        pkg = "plug";
        version = "${version}";
        sha256 = "a13ff6b9006b03d7e33874945b2755253841b238c34071ed85b0e86057f8cddc";
      };

      beamDeps = [ mime plug_crypto telemetry ];
    };

    plug_crypto = buildMix rec {
      name = "plug_crypto";
      version = "2.1.0";

      src = fetchHex {
        pkg = "plug_crypto";
        version = "${version}";
        sha256 = "131216a4b030b8f8ce0f26038bc4421ae60e4bb95c5cf5395e1421437824c4fa";
      };

      beamDeps = [];
    };

    postgrex = buildMix rec {
      name = "postgrex";
      version = "0.19.3";

      src = fetchHex {
        pkg = "postgrex";
        version = "${version}";
        sha256 = "d31c28053655b78f47f948c85bb1cf86a9c1f8ead346ba1aa0d0df017fa05b61";
      };

      beamDeps = [ db_connection decimal jason ];
    };

    publicist = buildMix rec {
      name = "publicist";
      version = "1.1.0";

      src = fetchHex {
        pkg = "publicist";
        version = "${version}";
        sha256 = "7ed86a54e87e48b7f2fb2d6bb365f0a5e46e987f843494c860dee61c357e2953";
      };

      beamDeps = [];
    };

    recase = buildMix rec {
      name = "recase";
      version = "0.8.1";

      src = fetchHex {
        pkg = "recase";
        version = "${version}";
        sha256 = "9fd8d63e7e43bd9ea385b12364e305778b2bbd92537e95c4b2e26fc507d5e4c2";
      };

      beamDeps = [];
    };

    req = buildMix rec {
      name = "req";
      version = "0.5.17";

      src = fetchHex {
        pkg = "req";
        version = "${version}";
        sha256 = "0b8bc6ffdfebbc07968e59d3ff96d52f2202d0536f10fef4dc11dc02a2a43e39";
      };

      beamDeps = [ finch jason mime plug ];
    };

    styler = buildMix rec {
      name = "styler";
      version = "0.11.9";

      src = fetchHex {
        pkg = "styler";
        version = "${version}";
        sha256 = "8b7806ba1fdc94d0a75127c56875f91db89b75117fcc67572661010c13e1f259";
      };

      beamDeps = [];
    };

    swoosh = buildMix rec {
      name = "swoosh";
      version = "1.17.3";

      src = fetchHex {
        pkg = "swoosh";
        version = "${version}";
        sha256 = "14ad57cfbb70af57323e17f569f5840a33c01f8ebc531dd3846beef3c9c95e55";
      };

      beamDeps = [ bandit finch jason mime plug req telemetry ];
    };

    tailwind = buildMix rec {
      name = "tailwind";
      version = "0.2.4";

      src = fetchHex {
        pkg = "tailwind";
        version = "${version}";
        sha256 = "c6e4a82b8727bab593700c998a4d98cf3d8025678bfde059aed71d0000c3e463";
      };

      beamDeps = [ castore ];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "1.3.0";

      src = fetchHex {
        pkg = "telemetry";
        version = "${version}";
        sha256 = "7015fc8919dbe63764f4b4b87a95b7c0996bd539e0d499be6ec9d7f3875b79e6";
      };

      beamDeps = [];
    };

    telemetry_metrics = buildMix rec {
      name = "telemetry_metrics";
      version = "1.0.0";

      src = fetchHex {
        pkg = "telemetry_metrics";
        version = "${version}";
        sha256 = "f23713b3847286a534e005126d4c959ebcca68ae9582118ce436b521d1d47d5d";
      };

      beamDeps = [ telemetry ];
    };

    telemetry_poller = buildRebar3 rec {
      name = "telemetry_poller";
      version = "1.1.0";

      src = fetchHex {
        pkg = "telemetry_poller";
        version = "${version}";
        sha256 = "9eb9d9cbfd81cbd7cdd24682f8711b6e2b691289a0de6826e58452f28c103c8f";
      };

      beamDeps = [ telemetry ];
    };

    thousand_island = buildMix rec {
      name = "thousand_island";
      version = "1.3.7";

      src = fetchHex {
        pkg = "thousand_island";
        version = "${version}";
        sha256 = "0139335079953de41d381a6134d8b618d53d084f558c734f2662d1a72818dd12";
      };

      beamDeps = [ telemetry ];
    };

    tiny_maps = buildMix rec {
      name = "tiny_maps";
      version = "3.0.0";

      src = fetchHex {
        pkg = "tiny_maps";
        version = "${version}";
        sha256 = "29246bb7fa7a96ced99cf1761d0e51b96b12d0eead1f0fb0e245919e70a6bd6a";
      };

      beamDeps = [];
    };

    websock = buildMix rec {
      name = "websock";
      version = "0.5.3";

      src = fetchHex {
        pkg = "websock";
        version = "${version}";
        sha256 = "6105453d7fac22c712ad66fab1d45abdf049868f253cf719b625151460b8b453";
      };

      beamDeps = [];
    };

    websock_adapter = buildMix rec {
      name = "websock_adapter";
      version = "0.5.8";

      src = fetchHex {
        pkg = "websock_adapter";
        version = "${version}";
        sha256 = "315b9a1865552212b5f35140ad194e67ce31af45bcee443d4ecb96b5fd3f3782";
      };

      beamDeps = [ bandit plug websock ];
    };
  };
in self
