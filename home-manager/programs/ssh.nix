{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        HashKnownHosts = "no";
      };
    };
  };
}
