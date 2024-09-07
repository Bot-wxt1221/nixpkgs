{
  stdenv,
  lib,
  fetchFromGitHub,
  enableZlib ? true,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scipopt";
  version = "v910";

  src = fetchFromGitHub {
    owner = "scipopt";
    repo = "scip";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-7yAPjepHzeVrWegp8+allI2BZVRFmwl8JfD64UrX6A0=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    soplex
  ];

  cmakeFlags =
    [
      "-B build"
    ]
    ++ lib.mkIf enableZlib [
      "-D -DZLIB_INCLUDE_DIR=${lib.getDev zlib}/include/"
      "-DZLIB_LIBRARY=${zlib}/lib"
    ];

  meta = {
    description = "Tools for Solving Constraint Integer Programs";
    changelog = "https://github.com/scipopt/scip/releases/tag/${finalAttrs.version}";
    homepage = "https://scipopt.org/";
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    license = lib.licenses.free;
    platform = lib.platforms.unix;
    mainProgram = "";
  };
})
