{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    taps = [
      {
        name = "Xoshbin/asyar";
        trusted = true; # Homebrew 6+ refuses casks from untrusted third-party taps
      }
      {
        name = "zzet/tap";
        trusted = true;
      }
    ];

    casks = [
      "kaku"
      "claude-code@latest"
      "asyar"
      "gortex"
    ];
  };
}
