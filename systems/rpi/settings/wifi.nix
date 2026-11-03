{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ../secrets.yaml;
    # The Mac's age key (~/.config/sops/age/keys.txt), copied to the SD card's FIRMWARE partition after flashing,
    # so the Pi can decrypt on its very first boot
    age = {
      keyFile = "/boot/firmware/sops-age.key";
      sshKeyPaths = [ ];
    };
    secrets.wifi = { };
  };

  # The SD image doesn't mount this partition; sops-nix needs it before services start.
  # Root-only, since it holds the key.
  fileSystems."/boot/firmware" = {
    neededForBoot = true;
    options = lib.mkForce [
      "nofail"
      "umask=0077"
    ];
  };

  # The SSID is a secret too: the repo is public, and a network name can be located on a map
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.sops.secrets.wifi.path ];
    profiles.home = {
      connection = {
        id = "home";
        type = "wifi";
      };
      wifi = {
        mode = "infrastructure";
        ssid = "$WIFI_SSID";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$WIFI_PSK";
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  };
}
