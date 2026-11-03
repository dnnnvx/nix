{ lib, user, ... }:

{
  # Shared by every Pi; per-Pi settings are in hosts/
  imports = [ ./settings/wifi.nix ];

  networking.networkmanager = {
    enable = true;
    # The Pi's Wi-Fi chip tends to drop connections with power saving on
    wifi.powersave = false;
  };
  time.timeZone = "Europe/Rome";

  # Answer to <hostname>.local on the LAN
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGDeA1xLN3r9IS6OKcYnMN/8SJ/nB7oh7TggL3TyCgn+"
    ];
  };

  # The user has no password, so sudo can't ask for one
  security.sudo.wheelNeedsPassword = false;

  # Compressed swap in RAM: headroom on the 1-2 GB Pis
  zramSwap.enable = true;

  documentation.enable = false;

  # Enabled by the SD image's base profile; unused here and pulls in kernel modules
  boot.supportedFilesystems.zfs = lib.mkForce false;

  boot.loader.generic-extlinux-compatible.configurationLimit = 5;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    optimise.automatic = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Lets the Mac copy its unsigned builds when deploying
      trusted-users = [ user ];
    };
  };

  system.stateVersion = "26.05";
}
