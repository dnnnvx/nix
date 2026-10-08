{ ... }: {
  programs.tmux = {
    enable = true;
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

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind r source-file ~/.config/tmux/tmux.conf

      bind C-j resize-pane -D 3
      bind C-k resize-pane -U 3
      bind C-l resize-pane -R 3
      bind C-h resize-pane -L 3

      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "pbcopy"

      set -g status-position bottom
      set -g status-bg colour234
      set -g status-fg colour137
      set -g status-left ""
      set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
      set -g status-right-length 50
      set -g status-left-length 20

      setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '
      setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
    '';
  };
}
