{
  description = "Dora CLI package for Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = {
          dora-cli = pkgs.rustPlatform.buildRustPackage rec {
            pname = "dora-cli";
            version = "0.3.6";

            src = pkgs.fetchFromGitHub {
              owner = "dora-rs";
              repo = "dora";
              rev = "v${version}";
              hash = "sha256-YwEqwA7Eqz7ZJYFfKoPTWkmgsudKpoATcFE6OOwxpbU=";
            };

            cargoHash = "sha256-vdKA4qfoWEgTOaR1Deve87GiIiKq3uRpuGo66+IflTg=";
            nativeBuildInputs = [ pkgs.pkg-config ];
            buildInputs = [ pkgs.openssl ];
            OPENSSL_NO_VENDOR = 1;
            buildPhase = ''
              cargo build --release -p dora-cli
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp target/release/dora $out/bin
            '';

            doCheck = false;

            meta = {
              description = "Making robotic applications fast and simple!";
              homepage = "https://dora-rs.ai/";
              changelog = "https://github.com/dora-rs/dora/blob/main/Changelog.md";
              license = pkgs.lib.licenses.asl20;
            };
          };
        };
        devShells = {
          default = pkgs.mkShell {
            name = "dora-cli";
            venvDir = "./.venv";
            buildInputs = [
              self.packages.${pkgs.system}.dora-cli

              pkgs.rustc
              pkgs.cargo
              pkgs.rustPlatform.bindgenHook
              pkgs.rust-analyzer
              pkgs.zenoh

              # A Python interpreter including the 'venv' module is required to bootstrap
              # the environment.
              pkgs.python3Packages.python

              # This executes some shell code to initialize a venv in $venvDir before
              # dropping into the shell
              pkgs.python3Packages.venvShellHook

              pkgs.python3Packages.pyarrow
              pkgs.python3Packages.uv
            ];

            # Run this command, only after creating the virtual environment
            postVenvCreation = ''
              unset SOURCE_DATE_EPOCH
              # pip install -r requirements.txt

            '';
            postShellHook = ''
              export CARGO_HOME=$(pwd)/.cargo
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${
                pkgs.lib.makeLibraryPath [
                  pkgs.libGL
                  pkgs.wayland
                  pkgs.libxkbcommon
                ]
              };
            '';
          };
        };
        checks = self.packages;
      }
    );
}
