{ config, lib, ... }:
{
  options.handsets.audio.enable = lib.mkEnableOption "desktop-neutral PipeWire audio";
  config = lib.mkIf config.handsets.audio.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
