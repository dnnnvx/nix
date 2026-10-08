{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      character.success_symbol = "[➟](bold blue) ";
      character.error_symbol = "[✗](bold red) ";
      # Hide the username. The username will only show in certain scenarios
      username.disabled = false;
      hostname.disabled = false;
      hostname.ssh_only = true;
      hostname.format = "[$hostname](bold #d17dd7) [>](bold green) ";
      # hostname.trim_at = ".companyname.com";
      directory.truncation_length = 25;
      directory.truncate_to_repo = true;
      directory.format = "[$path]($style)[$read_only]($read_only_style) ";
      directory.read_only = " 🔒";
      directory.read_only_style = "red";
      directory.style = "bold blue";
      cmd_duration.disabled = false;
      cmd_duration.min_time = 4;
      cmd_duration.show_milliseconds = false;
      cmd_duration.format = "[$duration](bold yellow)";
      cmd_duration.style = "bold italic blue";
    };
  };
}
