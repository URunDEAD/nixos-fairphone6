{ pkgs, hardwareSource, kernelSource ? pkgs.requireFile {
    name = "linux-63289f4411520a2acb38bd533437446d33fbce74.tar.gz";
    sha256 = "1a1aba170899273cbb97bce2dc0713957340a7be2e2d187faab6f821d60687ba";
    meta.license = pkgs.lib.licenses.gpl2Only;
    message = "Supply the verified milos-linux archive described in docs/BUILDING.md; no binary firmware is fetched.";
  }
}:
let
  source = kernelSource;
  kernel = pkgs.linuxManualConfig {
    pname = "linux-fp6-nixos";
    version = "7.2.0";
    modDirVersion = "7.2.0-fp6-nixos6";
    src = source;
    configfile = "${hardwareSource}/kernel/feature-push/kernel6/config.final";
    kernelPatches = [
      { name = "gmu-fw-init-timeout-100ms"; patch = "${hardwareSource}/kernel/gmu-timeout/gmu-fw-init-timeout-100ms.patch"; }
      { name = "qcomtee-large-shm-cma"; patch = "${hardwareSource}/kernel/qcomtee-cma/qcomtee-large-shm-cma.patch"; }
      { name = "milos-dphy-no-cphy-rate-table"; patch = "${hardwareSource}/kernel/selfie-dphy/milos-dphy-no-cphy-rate-table.patch"; }
      { name = "qcom-battmgr-charge-uah"; patch = "${hardwareSource}/kernel/feature-push/misc/0001-power-supply-qcom_battmgr-report-charge-in-uAh-on-SM8350-family.patch"; }
      { name = "stk3310-noirq-polling"; patch = "${hardwareSource}/kernel/feature-push/sensors/0001-iio-light-stk3310-noirq-polling-event-free.patch"; }
      { name = "stk3310-retry-bus-errors"; patch = "${hardwareSource}/kernel/feature-push/sensors/0002-iio-light-stk3310-retry-transient-bus-errors.patch"; }
      { name = "eswin-eph861x-gesture-wake"; patch = "${hardwareSource}/kernel/feature-push/sensors/0003-input-eswin-eph861x-gesture-wake-pm-lp-mode.patch"; }
      { name = "ufs-qcom-milos-spm-lvl5"; patch = "${hardwareSource}/kernel/feature-push/suspend/0001-scsi-ufs-qcom-milos-power-down-link-in-system-suspend.patch"; }
    ];
    stdenv = pkgs.llvmPackages.stdenv;
    # Nixpkgs sets absolute GNU tool paths even when LLVM=1; override the
    # target tools explicitly so ThinLTO uses the matching LLVM toolchain.
    extraMakeFlags = [
      "LLVM=1"
      "LD=${pkgs.llvmPackages.lld}/bin/ld.lld --thinlto-jobs=2"
      "AR=${pkgs.llvmPackages.llvm}/bin/llvm-ar"
      "NM=${pkgs.llvmPackages.llvm}/bin/llvm-nm"
      "STRIP=${pkgs.llvmPackages.llvm}/bin/llvm-strip"
      "OBJCOPY=${pkgs.llvmPackages.llvm}/bin/llvm-objcopy"
      "OBJDUMP=${pkgs.llvmPackages.llvm}/bin/llvm-objdump"
      "READELF=${pkgs.llvmPackages.llvm}/bin/llvm-readelf"
      "HOSTCC=${pkgs.llvmPackages.clang}/bin/clang"
      "HOSTCXX=${pkgs.llvmPackages.clang}/bin/clang++"
      # Host tools need the wrapped linker to retain dependency RPATHs.
      "HOSTLDFLAGS=--ld-path=${pkgs.buildPackages.stdenv.cc.bintools}/bin/ld"
    ];
    target = "Image.gz";
    buildDTBs = true;
    features.efiBootStub = true;
  };
in kernel.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
    pkgs.llvmPackages.lld
    pkgs.llvmPackages.llvm
  ];
  # EFI_ZBOOT changes arm64 zinstall's default to vmlinuz.efi. Install the
  # explicitly built gzip image used by the FP6 Android boot image instead.
  installFlags = (old.installFlags or []) ++ [
    "KBUILD_IMAGE=arch/arm64/boot/Image.gz"
  ];
  passthru = old.passthru // { file = "Image.gz"; isQcdt = false; isExynosDT = false; };
})
