{ pkgs, ... }:

{
  environment = {
    shells = [ pkgs.zsh ];

    # Apple Silicon Homebrew first, ahead of the Intel (Rosetta) prefix in /usr/local
    systemPath = [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
      "/usr/local/bin"
      "$HOME/go/bin"
      "$HOME/.local/bin"
    ];

    variables = {
      SHELL = "${pkgs.zsh}/bin/zsh";
      LANG = "en_US.UTF-8";
    };

    shellAliases = {
      ls = "ls --color";
      ll = "ls -alt --color";
      k = "kubectl";
      kevents = "kubectl get events --sort-by=.metadata.creationTimestamp";
    };
  };
}
