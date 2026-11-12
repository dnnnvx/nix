{ inputs, ... }:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # flake.nix makes nixvim follow our nixpkgs, explicitly silences its warning
    nixpkgs.source = inputs.nixpkgs;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      number = true;
      relativenumber = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      wrap = false;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      ignorecase = true;
      smartcase = true;
      splitright = true;
      splitbelow = true;
      undofile = true;
      updatetime = 250;
      autoread = true;
      clipboard = "unnamedplus"; # share the macOS clipboard
    };

    colorschemes.github-theme = {
      enable = true;
      settings.options.transparent = false;
    };
    colorscheme = "github_dark_dimmed";

    # Reload buffers changed outside nvim
    autoCmd = [
      {
        event = [
          "FocusGained"
          "BufEnter"
          "CursorHold"
          "TermLeave"
        ];
        command = "if mode() != 'c' | checktime | endif";
      }
    ];

    plugins = {
      # Fuzzy picker, file-tree sidebar and lazygit popup
      snacks = {
        enable = true;
        settings = {
          picker.enabled = true;
          explorer.enabled = true;
          lazygit.enabled = true;
          indent.enabled = true;
          notifier.enabled = true;
        };
      };
      mini-icons = {
        enable = true;
        mockDevIcons = true;
      };

      which-key.enable = true; # shows available keys after <leader>
      lualine.enable = true;
      gitsigns.enable = true;
      tmux-navigator.enable = true; # C-h/j/k/l move across nvim splits and tmux panes

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };
      # Node-level editing: `vaf` selects a function, `cia` changes an argument, `]f` jumps to next function
      treesitter-textobjects = {
        enable = true;
        settings = {
          select = {
            enable = true;
            lookahead = true;
            keymaps = {
              af = "@function.outer";
              "if" = "@function.inner";
              ac = "@class.outer";
              ic = "@class.inner";
              aa = "@parameter.outer";
              ia = "@parameter.inner";
            };
          };
          move = {
            enable = true;
            set_jumps = true;
            goto_next_start."]f" = "@function.outer";
            goto_previous_start."[f" = "@function.outer";
          };
        };
      };

      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          rust_analyzer = {
            enable = true;
            package = null; # from rustup
            installCargo = false;
            installRustc = false;
          };
        };
        keymaps.lspBuf = {
          gd = "definition";
          gr = "references";
          K = "hover";
          "<leader>ca" = "code_action";
          "<leader>rn" = "rename";
        };
      };
      blink-cmp.enable = true;

      # Bridge to a `claude` running in tmux: in Claude run `/ide` to connect.
      # Claude then sees the current file/selection and opens its diffs here to accept/reject.
      claudecode = {
        enable = true;
        settings.terminal.provider = "none";
      };
    };
    dependencies.claude-code.enable = false; # comes from Homebrew

    keymaps =
      let
        lua = key: action: desc: {
          mode = "n";
          inherit key;
          action.__raw = "function() ${action} end";
          options.desc = desc;
        };
      in
      [
        (lua "<leader><space>" "Snacks.picker.smart()" "Find files (smart)")
        (lua "<leader>ff" "Snacks.picker.files()" "Find files")
        (lua "<leader>fg" "Snacks.picker.grep()" "Grep project")
        (lua "<leader>fb" "Snacks.picker.buffers()" "Open buffers")
        (lua "<leader>fr" "Snacks.picker.recent()" "Recent files")
        (lua "<leader>e" "Snacks.explorer()" "File tree sidebar")
        (lua "<leader>gg" "Snacks.lazygit()" "Lazygit")
        (lua "<leader>gd" "Snacks.picker.git_diff()" "Git diff hunks")
        {
          mode = "n";
          key = "<leader>as";
          action = "<cmd>ClaudeCodeAdd %<cr>";
          options.desc = "Send file to Claude";
        }
        {
          mode = "v";
          key = "<leader>as";
          action = "<cmd>ClaudeCodeSend<cr>";
          options.desc = "Send selection to Claude";
        }
        {
          mode = "n";
          key = "<leader>aa";
          action = "<cmd>ClaudeCodeDiffAccept<cr>";
          options.desc = "Accept Claude diff";
        }
        {
          mode = "n";
          key = "<leader>ad";
          action = "<cmd>ClaudeCodeDiffDeny<cr>";
          options.desc = "Reject Claude diff";
        }
        {
          mode = "n";
          key = "<Esc>";
          action = "<cmd>nohlsearch<cr>";
        }
      ];
  };
}
