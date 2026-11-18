{ config, lib, ... }:
{
  config = lib.mkIf config.handsets.sensors.enable {
    services.udev.extraRules = ''
      SUBSYSTEM=="misc", KERNEL=="fastrpc-*", ENV{IIO_SENSOR_PROXY_TYPE}=""
    '';
    systemd.services.iio-sensor-proxy = {
      wantedBy = [ "multi-user.target" ];
      startLimitIntervalSec = 60;
      startLimitBurst = 3;
      serviceConfig = { Restart = "on-failure"; RestartSec = 5; };
    };
  };
}
