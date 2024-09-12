{
  stdenv,
  cmake,
  lib,
  fetchFromGitLab,
  qt6,
}:

stdenv.mkDerivation(finalAttrs:{
  pname = "screenplay";
  version = "0.15.3";

  src = fetchFromGitLab{
    owner = "kelteseth";
    repo = "ScreenPlay";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    qt6.qtbase
  ];
})
