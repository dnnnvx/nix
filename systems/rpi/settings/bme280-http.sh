# Answers one HTTP request with the current BME280 readings as JSON, for Home Assistant.
# systemd starts one copy per connection, with the connection as stdin/stdout.
#
# Needs: BME280_ADDRESS, the I2C address in hex without "0x" (e.g. "77")

# Read the request headers until the empty line, and ignore them:
# closing the connection before reading the request would reset it
while IFS= read -r -t 2 line && [ -n "${line%$'\r'}" ]; do :; done

# The kernel driver exposes the readings as files
dev=$(echo /sys/bus/i2c/devices/*-00"$BME280_ADDRESS"/iio:device*)
if [ ! -r "$dev/in_temp_input" ]; then
  printf 'HTTP/1.0 503 Service Unavailable\r\nContent-Type: text/plain\r\n\r\nBME280 not found\n'
  exit 0
fi

# The kernel reports millidegrees, milli-percent and kPa
awk \
  -v t="$(cat "$dev/in_temp_input")" \
  -v h="$(cat "$dev/in_humidityrelative_input")" \
  -v p="$(cat "$dev/in_pressure_input")" \
  'BEGIN {
    printf "HTTP/1.0 200 OK\r\nContent-Type: application/json\r\n\r\n"
    printf "{\"temperature\": %.2f, \"humidity\": %.2f, \"pressure\": %.2f}\n", t / 1000, h / 1000, p * 10
  }'
