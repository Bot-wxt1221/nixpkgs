{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
}:

stdenv.stdenv.mkDerivation (finalAttrs: {
  pname = "shadps4";
  version = "v.0.2.0";

  src = fetchFromGitHub {
    owner = "shadps4-emu";
    repo = "shadPS4";
    rev = "refs/tags/${version}";
    hash = "";
  }

  buildInputs = [
    cmake
  ];

  meta = {
    description = "Early PlayStation 4 emulator for Windows, Linux and macOS written in C++.";
    homepage = "https://shadps4.net/";
    changelog = "https://github.com/shadps4-emu/shadPS4/releases/tag/${version}";
    mainProgram = "";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platform = lib.platforms.unix;
  };
})
