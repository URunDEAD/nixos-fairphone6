{ config, lib, handsetPackages, ... }:
let ucmPath = "${handsetPackages.ucm-fairphone6}/share/alsa/ucm2";
    services = lib.genAttrs [ "pipewire" "pipewire-pulse" "wireplumber" ] (_: { environment.ALSA_CONFIG_UCM2 = ucmPath; });
in {
  config = lib.mkIf config.handsets.audio.enable {
    environment.variables.ALSA_CONFIG_UCM2 = ucmPath;
    systemd.user.services = lib.mkIf (!config.services.pipewire.systemWide) services;
    systemd.services = lib.mkIf config.services.pipewire.systemWide services;
    services.pipewire.wireplumber.extraConfig."51-fp6-alsa"."monitor.alsa.rules" = [{
      matches = [ { "node.name" = "~alsa_input.platform-sound.*"; } { "node.name" = "~alsa_output.platform-sound.*"; } ];
      actions.update-props = {
        "audio.format" = "S16LE"; "audio.rate" = 48000;
        "api.alsa.period-size" = 4096; "api.alsa.period-num" = 6; "api.alsa.headroom" = 512;
      };
    }];
  };
}
