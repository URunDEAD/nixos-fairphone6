{ config, lib, pkgs, ... }:
let cfg = config.handsets.fairphone6;
in {
  mobile.system.type = "android";
  mobile.system.android = {
    ab_partitions = true;
    boot_as_recovery = false;
    has_recovery_partition = false;
    device_name = "FP6";
    bootimg.flash = {
      offset_base = "0x00000000"; offset_kernel = "0x00008000";
      offset_ramdisk = "0x01000000"; offset_second = "0x00000000";
      offset_tags = "0x00000100"; pagesize = "4096";
    };
  };
  mobile.quirks.supportsStage-0 = false;
  mobile.outputs.android.android-bootimg = lib.mkForce (pkgs.runCommand "fairphone6-reference-boot.img" {
    nativeBuildInputs = [ pkgs.buildPackages.python3 ];
  } ''
    python3 ${./repack-boot.py} ${cfg.bootTemplate} \
      ${cfg.kernelPackage}/${cfg.kernelPackage.file} \
      ${config.mobile.outputs.initrd} \
      ${cfg.kernelPackage}/dtbs/qcom/milos-fairphone-fp6.dtb "$out" \
      --cmdline ${lib.escapeShellArg (lib.concatStringsSep " " config.boot.kernelParams)}
  '');
  # Export build artifacts only: no auto-flash, slot switch or activation script.
  mobile.outputs.android.android-fastboot-images = lib.mkForce (pkgs.runCommand "fairphone6-reference-images" {} ''
    mkdir -p "$out"
    cp ${config.mobile.outputs.android.android-bootimg} "$out/boot.img"
    echo 'Unqualified reference artifact. No flashing or slot switching is authorized by this package.' > "$out/README.txt"
  '');
}
