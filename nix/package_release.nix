{
  rustPlatform,
  fetchFromGitHub,
  lib,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "dora-cli";

  version = "0.3.13";

  src = fetchFromGitHub {
    owner = "dora-rs";
    repo = "dora";
    rev = "v${version}";
    hash = "sha256-X84r60CbzOfT1f58UsNARDG6ZxT2j6b8IvmJAnl2p5k=";
  };

  cargoHash = "sha256-/v6CXTHFUZFn7Et3xzgeYyHUYwpmMSIak9S2wFiYoK8=";
  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl];
  OPENSSL_NO_VENDOR = 1;
  buildPhase = ''
    cargo build --release -p dora-cli
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp target/release/dora $out/bin
  '';

  # doCheck = false;

  meta = {
    description = "Making robotic applications fast and simple!";
    homepage = "https://dora-rs.ai/";
    changelog = "https://github.com/dora-rs/dora/blob/main/Changelog.md";
    license = lib.licenses.asl20;
  };
}
