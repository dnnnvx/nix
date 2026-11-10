{ ... }:
{
  programs.zed-editor = {
    enable = true;
    package = null; # Zed.app is installed outside Nix

    # Theme extensions referenced below; installed on Zed's next launch
    extensions = [
      "catppuccin-icons"
      "github-theme"
    ];

    # Merged into ~/.config/zed/settings.json, which stays writable from Zed's UI
    userSettings = {
      theme = "GitHub Dark Dimmed";
      icon_theme = "Catppuccin Frappé";
      ui_font_size = 16;
      buffer_font_size = 15;
      buffer_line_height = "comfortable";
      terminal.font_size = 12;

      cursor_shape = "block";
      cursor_blink = false;

      vim_mode = true;
      vim.cursor_shape = {
        normal = "block";
        insert = "block";
        replace = "block";
        visual = "block";
      };

      project_panel.dock = "right";
      outline_panel.dock = "right";
      collaboration_panel.dock = "right";
      git_panel.dock = "right";
      agent.dock = "left";
    };

    # Merged into ~/.config/zed/keymap.json
    userKeymaps = [
      {
        context = "Terminal";
        bindings = {
          # Send ESC+CR so TUIs get a newline instead of submit
          "shift-enter" = [
            "terminal::SendText"
            (builtins.fromJSON ''"\u001b\r"'')
          ];
        };
      }
    ];
  };
}
