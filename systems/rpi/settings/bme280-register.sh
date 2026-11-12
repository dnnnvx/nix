# Tells the kernel's bme280 driver that the sensor is on the GPIO 2/3 I2C bus.
# The sensor isn't in the device tree, so the kernel can't find it on its own.
# Once registered, the readings show up as files under /sys (see bme280-http.sh).
#
# Needs: BME280_ADDRESS, the I2C address in hex without "0x" (e.g. "77")

# The GPIO 2/3 bus has no fixed number (i2c-1, i2c-20, ...),
# so find it by its hardware address instead
gpio_bus="i2c@7e804000"

# The I2C driver loads asynchronously at boot: retry for up to 30 seconds
for _ in $(seq 30); do
  for bus in /sys/bus/i2c/devices/i2c-*; do
    [ "$(basename "$(readlink -f "$bus/of_node")")" = "$gpio_bus" ] || continue

    # A device at address 0x77 on bus i2c-N shows up as N-0077
    number="${bus##*-}"
    if [ ! -e "/sys/bus/i2c/devices/$number-00$BME280_ADDRESS" ]; then
      echo "bme280 0x$BME280_ADDRESS" > "$bus/new_device"
    fi
    exit 0
  done
  sleep 1
done

# Don't fail: a failed unit would make every deploy report an error
echo "GPIO I2C bus not found" >&2
