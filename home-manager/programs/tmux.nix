{ pkgs, ... }:
let
  p = import ../palette.nix;
in
{
  programs.tmux = {
    enable = true;
    # C-h/j/k/l (no prefix) move across tmux panes and nvim splits; pairs with nvim's tmux-navigator
    # (C-l is unbound in extraConfig so shells keep it for clear)
    plugins = [ pkgs.tmuxPlugins.vim-tmux-navigator ];
    keyMode = "vi";
    prefix = "C-u";
    terminal = "tmux-256color";
    historyLimit = 20000;
    baseIndex = 1;
    escapeTime = 0;
    aggressiveResize = true;
    mouse = false;
    extraConfig = ''
      bind-key u last-window
      bind-key e send-prefix

      set -as terminal-overrides ',xterm*:Tc:sitm=\E[3m'
      set -as terminal-overrides ",*:RGB"

      set -g renumber-windows on

      # nvim reloads files edited by Claude Code on FocusGained
      set -g focus-events on
      # pass modified keys (e.g. shift-enter for a newline in Claude Code) through to apps
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind r source-file ~/.config/tmux/tmux.conf

      bind C-j resize-pane -D 3
      bind C-k resize-pane -U 3
      bind C-l resize-pane -R 3
      bind C-h resize-pane -L 3

      # give C-l back to the shell (clear); nvim's navigator still jumps right from vim
      unbind -n C-l

      # previous/next window without the prefix
      bind -n M-h previous-window
      bind -n M-l next-window

      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "pbcopy"

      set -g status-position bottom
      # colours must be quoted: an unquoted #rrggbb starts a tmux comment
      set -g status-style 'bg=${p.bg-raised},fg=${p.fg}'
      setw -g window-status-current-style 'bg=${p.selection}'
      # git branch of the workspace folder (● = uncommitted changes), refreshed every 5s
      set -g status-interval 5
      set -g status-right '#(~/.config/tmux/bin/tmux-agent git "#{session_path}")#[default] #[bg=${p.selection},fg=${p.blue},bold] %d/%m #[default] #[bg=${p.selection},fg=${p.cyan},bold] %H:%M:%S '
      set -g status-right-length 80
      # status-left and window formats live in tmux-agents.nix (workspaces + Claude markers)
    '';
  };
}
