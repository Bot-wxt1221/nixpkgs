{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6,
  libarchive,
  libpng,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "CEmu";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "CE-Programming";
    repo = "CEmu";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fohsIJrvPDMmYHoPbmYQlKLMnj/B3XEBaerZYuqxvd8=";
    fetchSubmodules = true;
  };

  sourceRoot = "${finalAttrs.src.name}/gui/qt/";

  patches = [
    ./0001-Resolve-ambiguous-overloaded-function-argument.patch
  ];

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    libarchive
    libpng
  ];

  meta = {
    description = "Third-party TI-84 Plus CE / TI-83 Premium CE emulator, focused on developer features";
    mainProgram = "CEmu";
    homepage = "https://ce-programming.github.io/CEmu";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ luc65r ];
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
    ];
    broken = stdenv.hostPlatform.isDarwin;
  };
})
