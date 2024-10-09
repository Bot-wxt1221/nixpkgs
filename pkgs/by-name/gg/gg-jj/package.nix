{
  rustPlatform,
  callPackage,
  pkg-config,
  lib,
  fetchFromGitHub,
  libayatana-appindicator,
  openssl,
  webkitgtk_4_1,
  cargo-tauri,
  fetchNpmDeps,
  wrapGAppsHook3,
  nodejs,
  npmHooks
}:

rustPlatform.buildRustPackage rec {
  pname = "gg-jj";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "gulbanana";
    repo = "gg";
    rev = "refs/tags/v${version}";
    hash = "sha256-xOi/AUlH0FeenTXz3hsDYixCEl+yr22PGy6Ow4TKxY0=";
  };

  npmDeps = fetchNpmDeps {
    name = "${pname}-webui";
    inherit src;
    hash = "sha256-oHBFuX65D/FgnGa03jjpIKAdH8Q4c2NrpD64bhfe720=";
  };

  sourceRoot = "${src.name}/src-tauri";

  env = {
    OPENSSL_NO_VENDOR = 1;
  };

  buildInputs = [
    webkitgtk_4_1
    openssl
  ];

  npmRoot = "..";

  buildAndTestDir = ".";

  nativeBuildInputs = [
    pkg-config
    cargo-tauri.hook
    nodejs
    npmHooks.npmConfigHook
    wrapGAppsHook3
  ];

  cargoHash = "sha256-1g0MQi10+qeRrcsSQXdtj6TrktMjnAM3tIrkeRudGk8=";

  postPatch = ''
    chmod +w ..

    pushd $cargoDepsCopy/libappindicator-sys
    oldHash=$(sha256sum src/lib.rs | cut -d " " -f 1)
    substituteInPlace src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
    substituteInPlace .cargo-checksum.json \
      --replace-fail $oldHash $(sha256sum src/lib.rs | cut -d " " -f 1)
    popd

    pushd $cargoDepsCopy/jj-cli
    oldHash=$(sha256sum build.rs | cut -d " " -f 1)
    substituteInPlace build.rs \
      --replace-fail 'let path = std::env::var("CARGO_MANIFEST_DIR").unwrap();' "let path = \"$cargoDepsCopy/jj-cli\";"
    substituteInPlace .cargo-checksum.json \
      --replace-fail $oldHash $(sha256sum build.rs | cut -d " " -f 1)
    popd
  '';

  meta = {
    homepage = "https://github.com/gulbanana/gg";
    changelog = "https://github.com/gulbanana/gg/releases/tag/v${version}";
    description = "GUI for jj users";
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    mainProgram = "gg";
    license = lib.licenses.apsl20;
  };
}
