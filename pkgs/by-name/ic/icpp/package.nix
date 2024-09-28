{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  python3
}:

stdenv.mkDerivation(finalAttrs:{
  pname = "icpp";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "vpand";
    repo = "icpp";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    python3
  ];
})
