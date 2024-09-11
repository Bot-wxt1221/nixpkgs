{
  rustPlatform,
  lib,
  fetchFromGitHub,
  callPackage,
}:

rustPlatform.buildRustPackage rec{
  pname = "yaak";
  version = "2024.8.2";

  src = fetchFromGitHub {
    owner = "yaakapp";
    repo = "app";
    rev = "refs/tags/v${version}";
    hash = "";
  };

  sourceRoot = "${src.name}/src-tauri";

  webui = callPackage ./webui.nix {
    inherit version src meta;
  };

  cargoHash = "";

  postInstall = ''
    mkdir -p $out
    cp -r ${webui}/* $out
  '';

  meta = {
    homepage = "";
  };
}
