{ ... }:

{
  imports = [
    ../settings/bme280.nix
    ../settings/mic-stream.nix
  ];

  networking.hostName = "rpi-1";
  rpi.address = "192.168.0.111";
}
