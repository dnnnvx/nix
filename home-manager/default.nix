{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  home.stateVersion = "25.05";

  imports = [
    ./programs/git.nix
    ./programs/helix.nix
    ./programs/ssh.nix
    ./programs/starship.nix
    ./programs/tmux.nix
    ./programs/zed.nix
    ./programs/zsh.nix
  ];

  home.sessionVariables = {
    PAGER = "less";
    CLICOLOR = 1;
  };

  home.packages = with pkgs; [
    nixfmt-tree
    htop
    curl
    coreutils
    jq
    zip
    xz
    unzip
    p7zip
    ripgrep
    yq-go
    dnsutils
    ldns # replacement of `dig`, it provide the command `drill`
    nmap # network discovery and security auditing
    tree
    gawk
    gnupg
    nerd-fonts.monaspace
    yazi
    git-extras
    lazygit
    inputs.pi.packages.${system}.default
    inputs.oh-my-pi.packages.${system}.default
  ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat.enable = true;

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # configs
  home.file.".ssh/allowed_signers".text = ''
    marco.destefani@proton.me ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGDeA1xLN3r9IS6OKcYnMN/8SJ/nB7oh7TggL3TyCgn+
  '';
  home.file.".omp/agent/models.yml".source = ./config/omp/models.yaml;

  # link all files in `./scripts` to `~/.local/bin`
  # home.file.".local/bin" = {
  #   source = ../scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };
}
