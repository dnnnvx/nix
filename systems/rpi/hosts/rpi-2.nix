{ ... }:

{
  imports = [ ../settings/gpio.nix ];

  networking.hostName = "rpi-2";
  rpi.address = "192.168.0.112";
}
