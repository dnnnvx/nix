{ ... }: {
  programs.helix = {
    enable = true;
    defaultEditor = true; # EDITOR=hx
  };

  xdg.configFile."helix/config.toml".source = ../config/helix/helix.toml;
}
