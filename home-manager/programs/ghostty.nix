{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin; # prebuilt macOS app; `ghostty` in nixpkgs is Linux-only
    enableZshIntegration = true;

    settings = {
      theme = "GitHub Dark Dimmed";
      font-family = "MonaspiceNe Nerd Font";
      font-size = 14;
      window-padding-x = 8;
      window-padding-y = 4;
      macos-option-as-alt = true;
      macos-titlebar-style = "tabs";
      cursor-style-blink = false;
      confirm-close-surface = false;
      copy-on-select = "clipboard";
    };
  };
}
