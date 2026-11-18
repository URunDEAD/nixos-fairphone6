{ config, lib, pkgs, handsetPackages, ... }:
let cfg = config.handsets.fairphone6;
in {
  imports = [ ./audio.nix ./sensors.nix ./boot.nix ];
  options.handsets.fairphone6 = {
    kernelPackage = lib.mkOption { type = lib.types.package; default = handsetPackages.kernel-fairphone6; };
    firmwarePackage = lib.mkOption { type = lib.types.package; description = "Explicit firmware package with lib/firmware; supplied by the consumer."; };
    rootDevice = lib.mkOption { type = lib.types.str; description = "Explicit root filesystem device; no inherited nested userdata layout."; };
    bootTemplate = lib.mkOption { type = lib.types.path; description = "Verified Android v2 template required by the preserved repacker; not redistributed."; };
  };
  options.mobile.hardware.socs.qualcomm-sm7635.enable = lib.mkEnableOption "Qualcomm SM7635";
  config = {
    assertions = [{ assertion = lib.hasPrefix "/dev/" cfg.rootDevice; message = "FP6 rootDevice must explicitly identify a /dev/ root filesystem."; }];
    mobile.device = {
      name = "fairphone-fp6";
      identity = { name = "Fairphone (Gen. 6)"; manufacturer = "Fairphone"; };
      supportLevel = "unsupported";
      firmware = cfg.firmwarePackage;
    };
    mobile.hardware = { soc = "qualcomm-sm7635"; ram = 8192; screen = { width = 1116; height = 2484; }; };
    mobile.system.system = "aarch64-linux";
    mobile.boot.stage-1 = {
      kernel.package = cfg.kernelPackage;
      kernel.modular = true;
      kernel.modules = [ "panel_novatek_nt37705" "spi_geni_qcom" ];
      compression = "zstd";
      firmware = [ cfg.firmwarePackage ];
    };
    hardware.enableRedistributableFirmware = false;
    hardware.firmware = [ cfg.firmwarePackage ];
    hardware.firmwareCompression = "none";
    boot.kernelModules = [ "panel_novatek_nt37705" "ath11k_ahb" "qcom_q6v5_pas" "inv_icm42600_spi" ];
    boot.growPartition = false;
    fileSystems."/" = { device = cfg.rootDevice; fsType = "ext4"; autoResize = false; };
    mobile.boot.boot-control.enable = false;
    # Preserve the original port's suspend guard until UFS resume is qualified.
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;
  };
}
