{ config, lib, ... }:
{
  options.handsets.sensors.enable = lib.mkEnableOption "IIO sensor proxy without a desktop dependency";
  config = lib.mkIf config.handsets.sensors.enable {
    hardware.sensor.iio.enable = true;
  };
}
