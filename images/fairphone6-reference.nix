# Import through lib.mkFairphone6 and provide explicit device inputs separately.
{ lib, ... }:
{
  system.stateVersion = "26.05";
  networking.hostName = lib.mkDefault "fairphone6";
  handsets.networking.enable = true;
  handsets.audio.enable = true;
  handsets.sensors.enable = true;
  documentation.nixos.enable = false;
  # No desktop, apps, automatic login, developer credentials, SSH or ADB.
  # Key-only SSH is an explicit, separate modules/development.nix opt-in.
}
