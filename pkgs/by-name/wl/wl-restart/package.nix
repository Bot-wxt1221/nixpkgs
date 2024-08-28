{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  scdoc,
  installShellFiles,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wl-restart";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Ferdi265";
    repo = "wl-restart";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pMsYLU9pjN2cgz7FxJJwkDHKJt1mIAuagJSBjrPUMAM=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp wl-restart $out/bin
    installManPage man/wl-restart.1

    runHook postInstall
  '';

  nativeBuildInputs = [
    scdoc
    cmake
    installShellFiles
  ];

  meta = {
    description = "wl-restart is a simple tool that restarts your compositor when it crashes.";
    homepage = "https://github.com/Ferdi265/wl-restart";
    license = lib.licenses.gpl3Only;
    mainProgram = "wl-restart";
    maintainers = with lib.maintainers; [
      bot-wxt1221
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
