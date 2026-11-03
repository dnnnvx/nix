{ config, lib, ... }:

let
  inherit (config.rpi) address;
in
{
  options.rpi.address = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "192.168.0.111";
    description = ''
      Static LAN IPv4, matching the host's <name>.local.casasulgorgo.net record (infra repo, tofu `local_hosts`).
      Must be outside the router's DHCP pool. Null: DHCP.
    '';
  };

  config.sops = {
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
  config.fileSystems."/boot/firmware" = {
    neededForBoot = true;
    options = lib.mkForce [
      "nofail"
      "umask=0077"
    ];
  };

  # The SSID is a secret too: the repo is public, and a network name can be located on a map
  config.networking.networkmanager.ensureProfiles = {
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
      ipv4 =
        if address == null then
          { method = "auto"; }
        else
          {
            method = "manual";
            address1 = "${address}/24,192.168.0.1"; # the router
            dns = "192.168.0.201;192.168.0.1;"; # AdGuard, then the router if the cluster is down
          };
      ipv6.method = "auto";
    };
  };
}
