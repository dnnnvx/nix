{ pkgs, ... }:

let
  port = 9280;
  # Seengreat board default (ADDR pin high); 0x76 if ADDR is tied to GND. Check with `sudo i2cdetect -y <bus>`
  address = "77";

  # One run per HTTP request: answers with the current readings as JSON, for Home Assistant
  readings = pkgs.writeShellScript "bme280-http" ''
    # Drain the request, so closing the connection doesn't reset it
    while IFS= read -r -t 2 line && [ -n "''${line%$'\r'}" ]; do :; done

    dev=$(echo /sys/bus/i2c/devices/*-00${address}/iio:device*)
    if [ ! -r "$dev/in_temp_input" ]; then
      printf 'HTTP/1.0 503 Service Unavailable\r\nContent-Type: text/plain\r\n\r\nBME280 not found\n'
      exit 0
    fi

    # The kernel reports millidegrees, milli-percent and kPa
    ${pkgs.gawk}/bin/awk \
      -v t="$(cat "$dev/in_temp_input")" \
      -v h="$(cat "$dev/in_humidityrelative_input")" \
      -v p="$(cat "$dev/in_pressure_input")" \
      'BEGIN {
        printf "HTTP/1.0 200 OK\r\nContent-Type: application/json\r\n\r\n"
        printf "{\"temperature\": %.2f, \"humidity\": %.2f, \"pressure\": %.2f}\n", t / 1000, h / 1000, p * 10
      }'
  '';
in
{
  # /dev/i2c-* and i2cdetect, for debugging the wiring
  hardware.i2c.enable = true;
  environment.systemPackages = [ pkgs.i2c-tools ];

  # The sensor isn't in the device tree, so register it with the kernel's bme280 driver.
  # The GPIO 2/3 bus has no fixed number; find it by its hardware address instead.
  systemd.services.bme280 = {
    description = "Register the BME280 on the GPIO I2C bus";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # The I2C driver loads asynchronously at boot
      for _ in $(seq 30); do
        for bus in /sys/bus/i2c/devices/i2c-*; do
          [ "$(basename "$(readlink -f "$bus/of_node")")" = "i2c@7e804000" ] || continue
          [ -e "/sys/bus/i2c/devices/''${bus##*-}-00${address}" ] || echo bme280 0x${address} > "$bus/new_device"
          exit 0
        done
        sleep 1
      done
      # Don't fail: a failed unit would make every deploy report an error
      echo "GPIO I2C bus not found" >&2
    '';
  };

  systemd.sockets.bme280-http = {
    wantedBy = [ "sockets.target" ];
    listenStreams = [ (toString port) ];
    socketConfig.Accept = true;
  };
  systemd.services."bme280-http@".serviceConfig = {
    ExecStart = readings;
    StandardInput = "socket";
    StandardOutput = "socket";
    StandardError = "journal";
    DynamicUser = true;
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
