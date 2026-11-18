{ config, lib, ... }:
{
  options.handsets.networking.enable = lib.mkEnableOption "desktop-neutral NetworkManager support";
  config = lib.mkIf config.handsets.networking.enable {
    networking.networkmanager.enable = true;
    networking.useDHCP = lib.mkDefault false;
  };
}
