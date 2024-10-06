{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  sqlite,
  nix-update-script,
  ncurses,
  bash,
  substituteAll,
  linuxPackages,
  kernel ? linuxPackages.kernel,
  clang,
  libbpf,
  glibc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "procmon";
  version = "2.0.0.0";

  src = fetchFromGitHub {
    owner = "Sysinternals";
    repo = "ProcMon-for-Linux";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-yip9/dtfCbq/GyY2FBpuS+F3j3Pd6hbs7UpNM82ilKU=";
  };

  catch2 = fetchFromGitHub {
    owner = "catchorg";
    repo = "Catch2";
    rev = "refs/tags/v2.7.2";
    hash = "sha256-AiXGtYdEUaORBJWW7Zg+U5XpLMW4vci4SlxtJRyMnkA=";
  };

  src-SysinternalsEBPF = fetchFromGitHub {
    owner = "Sysinternals";
    repo = "SysinternalsEBPF";
    rev = "refs/tags/1.4.0.0";
    hash = "sha256-FK2ya416yFWvzT2YcMUCuj0S6rTdDLFiHgbZ/StHuoQ=";
  };

  kernelSrc = stdenv.mkDerivation {
    inherit (finalAttrs) meta;
    pname = "kernel-syscall";
    version = kernel.version;

    src = kernel.src;
    dontBuild = true;
    dontCheck = true;

    installPhase = ''
      install -Dm644 arch/x86/entry/syscalls/syscall_64.tbl $out
    '';
  };

  patches = [
    (substituteAll {
      src = ./0001-fix.patch;
      inherit (finalAttrs) catch2;
    })
    (substituteAll {
      src = ./0001-fix-syscall.patch;
      inherit (finalAttrs) kernelSrc;
      bash = lib.getExe bash;
    })
  ];

  hardeningDisable = [ "zerocallusedregs" ];

  nativeBuildInputs = [
    cmake
    clang
  ];

  buildInputs = [
    sqlite
    ncurses
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "set(CLANG_INCLUDES" 'set(CLANG_INCLUDES
      -I "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build/include/generated/uapi"
      -I "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build/arch/x86/include/generated"
      -I "${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/tools/include/nolibc"
      -I "${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/include"
      -I "${glibc.dev}/include"
      -I "${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/tools/include"
      -I "${libbpf}/include"
      -I "${finalAttrs.src-SysinternalsEBPF}/ebpfKern"
      -I "${finalAttrs.src-SysinternalsEBPF}"
      -I "${libbpf}/include/bpf"' \
      --replace-fail "/usr/bin/ld" "$LD"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Linux reimagining of the classic Procmon tool from the Sysinternals suite of tools for Windows";
    homepage = "https://github.com/Sysinternals/ProcMon-for-Linux";
    changelog = "https://github.com/Sysinternals/ProcMon-for-Linux/releases/tag/2.0.0.0";
    license = lib.licenses.mit;
    mainProgram = "";
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = [ "x86_64-linux" ];
  };
})
