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
  python3,
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

  ebpf-extra = stdenv.mkDerivation {
    inherit (finalAttrs) meta version;
    pname = "ebpf-extra";
    dontUnpack = true;
    dontBuild = true;
    dontCheck = true;
    nativeBuildInputs = [
      python3
    ];
    installPhase = ''
      mkdir -p $out
      python3 ${finalAttrs.src-SysinternalsEBPF}/generateUnameOffsets.py ${finalAttrs.src-SysinternalsEBPF}/offsetsNeeded.json PUBLIC_HEADER > $out/sysinternalsEBPFoffsets.h
      python3 ${finalAttrs.src-SysinternalsEBPF}/generateUnameOffsets.py ${finalAttrs.src-SysinternalsEBPF}/offsetsNeeded.json HEADER > $out/unameOffsets.h
    '';
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
    ./0001-tt.patch
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
      -D__x86_64__
      -I "${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/include/uapi"
      -I "${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/include"
      -I "${glibc.dev}/include"
      -I "${libbpf}/include"
      -I "${finalAttrs.src-SysinternalsEBPF}/ebpfKern"
      -I "${finalAttrs.src-SysinternalsEBPF}"
      -I "${finalAttrs.ebpf-extra}"
      -I "${libbpf}/include/bpf"' \
      --replace-fail "/usr/bin/ld" "$LD"
    substituteInPlace src/tracer/ebpf/kern/vmlinux.h \
      --replace-fail "long long" "long"
    substituteInPlace src/common/stack_trace.h \
      --replace-fail "uint64_t" "unsigned long long"
    substituteInPlace src/common/telemetry.h \
      --replace-fail "uint64_t" "unsigned long long"
    substituteInPlace src/tracer/ebpf/syscall_schema.h \
      --replace-fail "std::strcpy" "strcpy"
  '';

  env = {
    NIX_CFLAGS_COMPILE = toString [
      "-I ${finalAttrs.src-SysinternalsEBPF}"
      "-I ${finalAttrs.src-SysinternalsEBPF}/ebpfKern"
      "-I ${finalAttrs.ebpf-extra}"
    ];
  };

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
