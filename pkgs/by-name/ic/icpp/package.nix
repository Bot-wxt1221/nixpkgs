{
  clangStdenv,
  lib,
  fetchFromGitHub,
  cmake,
  python3,
  valgrind,
  pkg-config,
  libxml2,
  libedit,
  libunwind,
  ocaml,
}:

clangStdenv.mkDerivation(finalAttrs:{
  pname = "icpp";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "vpand";
    repo = "icpp";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-eAWZZdYveIxIBIdyuRKf2LjtC84mWq3FeQsQHTp35GA=";
    fetchSubmodules = true;
  };

  preConfigure = ''
    cmake -B clangconf -DCMAKE_BUILD_TYPE=Release ./cmake/clangconf
    cmake --build clangconf -- clang runtimes -j8
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    ocaml
    python3
  ];

  buildInputs = [
    valgrind
    libunwind
    libedit
    libxml2
  ];
})
