{ lib, buildLinux, fetchurl
, kernelPatches ? [ ]
, structuredExtraConfig ? {}
, extraMeta ? {}
, argsOverride ? {}
, ... } @ args:

let
  version = "6.8.9-rt11"; # updated by ./update-rt.sh
  branch = lib.versions.majorMinor version;
  kversion = builtins.elemAt (lib.splitString "-" version) 0;
in buildLinux (args // {
  inherit version;

  # modDirVersion needs a patch number, change X.Y-rtZ to X.Y.0-rtZ.
  modDirVersion = if (builtins.match "[^.]*[.][^.]*-.*" version) == null then version
    else lib.replaceStrings ["-"] [".0-"] version;

  src = fetchurl {
    url = "https://github.com/Bot-wxt1221/linux/archive/refs/heads/linux-6.8.y.tar.gz";
    sha256 = "sha256-ip0Ldk3LXjlnGLH5CT5opFLT2fxZuxpl8r+lzUMBGok=";
  };

  structuredExtraConfig = with lib.kernel; {
    PREEMPT_RT = yes;
    # Fix error: unused option: PREEMPT_RT.
    EXPERT = yes; # PREEMPT_RT depends on it (in kernel/Kconfig.preempt)
    # Fix error: option not set correctly: PREEMPT_VOLUNTARY (wanted 'y', got 'n').
    PREEMPT_VOLUNTARY = lib.mkForce no; # PREEMPT_RT deselects it.
    # Fix error: unused option: RT_GROUP_SCHED.
    RT_GROUP_SCHED = lib.mkForce (option no); # Removed by sched-disable-rt-group-sched-on-rt.patch.
  } // structuredExtraConfig;

  extraMeta = extraMeta // {
    inherit branch;
  };
} // argsOverride)
