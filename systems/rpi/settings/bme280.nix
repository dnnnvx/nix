{ lib, pkgs, ... }:

let
  port = 9280;
  # Seengreat board default (ADDR pin high); 0x76 if ADDR is tied to GND. Check with `sudo i2cdetect -y <bus>`
  address = "77";

  # writeShellApplication adds the shebang and `set -euo pipefail`, puts runtimeInputs
  # on PATH, and checks the script with shellcheck at build time
  register = pkgs.writeShellApplication {
    name = "bme280-register";
    runtimeInputs = [ pkgs.coreutils ];
    text = builtins.readFile ./bme280-register.sh;
  };

  readings = pkgs.writeShellApplication {
    name = "bme280-http";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
    ];
    text = builtins.readFile ./bme280-http.sh;
  };
in
{
  # /dev/i2c-* and i2cdetect, for debugging the wiring
  hardware.i2c.enable = true;
  environment.systemPackages = [ pkgs.i2c-tools ];

  systemd.services.bme280 = {
    description = "Register the BME280 on the GPIO I2C bus";
    wantedBy = [ "multi-user.target" ];
    environment.BME280_ADDRESS = address;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe register;
    };
  };

  # One bme280-http@ instance per connection to the port
  systemd.sockets.bme280-http = {
    wantedBy = [ "sockets.target" ];
    listenStreams = [ (toString port) ];
    socketConfig.Accept = true;
  };
  systemd.services."bme280-http@" = {
    environment.BME280_ADDRESS = address;
    serviceConfig = {
      ExecStart = lib.getExe readings;
      StandardInput = "socket";
      StandardOutput = "socket";
      StandardError = "journal";
      DynamicUser = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
