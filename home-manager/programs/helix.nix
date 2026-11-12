{ ... }: {
  programs.helix = {
    enable = true;
  };

  xdg.configFile."helix/config.toml".source = ../config/helix/helix.toml;
}
