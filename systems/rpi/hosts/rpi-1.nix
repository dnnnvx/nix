{ ... }:

{
  imports = [
    ../settings/bme280.nix
    ../settings/mic-stream.nix
  ];

  networking.hostName = "rpi-1";
}
