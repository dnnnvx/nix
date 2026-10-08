{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    history = {
      extended = true;
      expireDuplicatesFirst = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      save = 1000000;
      size = 1000000;
    };
  };
}
