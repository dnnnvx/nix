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
      # left Option is Alt (tmux's Alt+1…9); right Option still types @ # [ ] { } on the Italian layout
      macos-option-as-alt = "left";
      macos-titlebar-style = "tabs";
      cursor-style = "block";
      cursor-style-blink = false;
      # shell integration forces a bar cursor at the prompt; keep everything else it does
      shell-integration-features = "no-cursor";
      confirm-close-surface = false;
      copy-on-select = "clipboard";
    };
  };
}
