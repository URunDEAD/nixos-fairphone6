{ repo }:
let
  f = builtins.getFlake repo;
  lib = f.inputs.nixpkgs.lib;
  mkCommon = extra: (lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ f.nixosModules.common f.nixosModules.development { system.stateVersion = "26.05"; } extra ];
  }).config;
  defaults = mkCommon {};
  enabled = mkCommon {
    handsets.audio.enable = true;
    handsets.networking.enable = true;
    handsets.sensors.enable = true;
  };
  invalidDev = mkCommon { handsets.development.enable = true; };
  phone = (f.lib.mkFairphone6 {
    configuration = { pkgs, ... }: {
      imports = [ ../images/fairphone6-reference.nix ];
      handsets.fairphone6 = {
        kernelPackage = pkgs.linuxPackages.kernel;
        firmwarePackage = pkgs.emptyDirectory;
        rootDevice = "/dev/disk/by-label/EVALUATION_ONLY";
        bootTemplate = ./fixtures/boot-template.txt;
      };
    };
  }).config;
  failed = c: map (a: a.message) (lib.filter (a: !a.assertion) c.assertions);
in {
  commonDisabled = !defaults.handsets.audio.enable && !defaults.handsets.networking.enable && !defaults.handsets.sensors.enable;
  optIns = enabled.services.pipewire.enable && enabled.networking.networkmanager.enable && enabled.hardware.sensor.iio.enable;
  noDefaultSsh = !defaults.services.openssh.enable;
  emptyDevelopmentKeysRejected = builtins.elem "Development access requires an explicitly supplied SSH public key." (failed invalidDev);
  phone = {
    identity = phone.mobile.device.identity.name;
    system = phone.mobile.system.system;
    compression = phone.mobile.boot.stage-1.compression;
    rootDevice = phone.fileSystems."/".device;
    suspendDisabled = !phone.systemd.targets.suspend.enable;
    noDesktop = !phone.services.desktopManager.lomiri.enable && !phone.services.xserver.enable;
    noDebugAccess = !phone.services.openssh.enable && !phone.mobile.adbd.enable && !phone.mobile.boot.stage-1.ssh.enable;
    failedAssertions = failed phone;
  };
  packages = lib.mapAttrs (_: p: p.name) f.packages.aarch64-linux;
}
