{ pkgs, user, ... }:

{
  # gpiodetect/gpioinfo/gpioget/gpioset/gpiomon, for poking at the breadboard
  environment.systemPackages = [ pkgs.libgpiod ];

  # /dev/gpiochip* is root-only by default; let the gpio group use it without sudo
  users.groups.gpio = { };
  users.users.${user}.extraGroups = [ "gpio" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="gpio", KERNEL=="gpiochip*", GROUP="gpio", MODE="0660"
  '';
}
