{ pkgs, hardwareSource }:
{
  kernel-fairphone6 = pkgs.callPackage ./kernel-fairphone6.nix { inherit hardwareSource; };
  ucm-fairphone6 = pkgs.callPackage "${hardwareSource}/userspace/audio/ucm-package.nix" {
    voiceCallVerb = false;
    topMic = false;
  };
  libcamera-fairphone6 = pkgs.callPackage "${hardwareSource}/userspace/camera/libcamera/default.nix" {};
  libcamera-fairphone6-selfie = pkgs.callPackage "${hardwareSource}/userspace/camera/libcamera/selfie.nix" {};
  fingerprintd-fairphone6 = pkgs.callPackage "${hardwareSource}/userspace/fingerprint/fingerprintd-preserved-package.nix" {};
  imsd-fairphone6 = pkgs.callPackage "${hardwareSource}/userspace/modem/imsd/imsd-package.nix" {};
  csvoiced-fairphone6 = pkgs.callPackage "${hardwareSource}/userspace/audio/cs-call/package.nix" {};
  lpac-qrtr = pkgs.callPackage "${hardwareSource}/userspace/modem/lpac-qrtr.nix" {};
}
