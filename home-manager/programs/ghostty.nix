{ lib, pkgs, ... }:
let
  p = import ../palette.nix;
in
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin; # prebuilt macOS app; `ghostty` in nixpkgs is Linux-only
    enableZshIntegration = true;

    # built from ../palette.nix (ANSI 0-15, normal then bright)
    themes.palette = {
      background = p.bg;
      foreground = p.fg;
      cursor-color = p.fg;
      selection-background = p.selection;
      palette = lib.imap0 (i: c: "${toString i}=${c}") [
        p.bg p.red p.green p.yellow p.blue p.purple p.cyan p.white
        p.fg-subtle p.red-bright p.green-bright p.yellow-bright p.blue-bright p.purple-bright p.cyan-bright p.white
      ];
    };

    settings = {
      theme = "palette";
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
