{
  rustPlatform,
  lib,
  fetchFromGitHub,
  zlib,
  openssl,
  pkg-config,
  protobuf,
}:
rustPlatform.buildRustPackage rec {
  pname = "nearcore";
  version = "2.3.1";

  # https://github.com/near/nearcore/tags
  src = fetchFromGitHub {
    owner = "near";
    repo = "nearcore";
    rev = "refs/tags/${version}";
    hash = "sha256-U8SjyhjcuaecIEH7uyKcjXB0g5NnEq64gcbbedZRZmI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "";

  postPatch = ''
    substituteInPlace neard/build.rs \
      --replace 'get_git_version()?' '"nix:${version}"'
  '';
  env = {
    CARGO_PROFILE_RELEASE_CODEGEN_UNITS = "1";
    CARGO_PROFILE_RELEASE_LTO = "fat";
    NEAR_RELEASE_BUILD = "release";
    OPENSSL_NO_VENDOR = 1; # we want to link to OpenSSL provided by Nix
  };

  # don't build SDK samples that require wasm-enabled rust
#  buildAndTestSubdir = "neard";
  doCheck = false; # needs network

  buildInputs = [
    zlib
    openssl
  ];

  nativeBuildInputs = [
    pkg-config
    protobuf
    rustPlatform.bindgenHook
  ];

  # fat LTO requires ~3.4GB RAM
  requiredSystemFeatures = [ "big-parallel" ];

  meta = {
    description = "Reference client for NEAR Protocol";
    homepage = "https://github.com/near/nearcore";
    license = lib.licenses.gpl3;
    mainProgram = "";
    maintainers = with lib.maintainers; [ mikroskeem ];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
  };
}
