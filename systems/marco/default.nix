{ pkgs, user, ... }:

{
  imports = [
    ./settings/system.nix
    ./settings/environment.nix
    ./settings/homebrew.nix
    ./settings/ssh.nix
  ];

  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
  };

  programs.nix-index.enable = true;

  # Home Manager's zsh already runs compinit; skip the second one in /etc/zshrc
  programs.zsh.enableGlobalCompInit = false;

  # nix-darwin already pins the `nixpkgs` registry entry and NIX_PATH to this flake's nixpkgs
  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 6;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "@admin" ];
      extra-platforms = [ "x86_64-darwin" ];
    };
  };
}
