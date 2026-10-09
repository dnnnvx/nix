{ pkgs, ... }: {
  programs.git = {
    enable = true;
    settings = {
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      init.defaultBranch = "main";
      user = {
        name = "dnnnvx";
        email = "marco.destefani@proton.me";
      };
    };
    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
  };
}
