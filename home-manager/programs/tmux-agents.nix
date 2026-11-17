# tmux workspaces for Claude Code: one tmux session per project folder, and
# markers in the status bar saying which workspace and tab has an agent
# waiting on you, done, or working. Pieces:
#   ../config/tmux-agents/tmux.conf          appended after tmux.nix's extraConfig
#   ../config/tmux-agents/tmux-agent         helper script (workspaces + hook target)
#   ../config/tmux-agents/claude-hooks.json  merged into ~/.claude/settings.json on activation
{ lib, pkgs, ... }:
let
  dir = ../config/tmux-agents;
in
{
  programs.tmux.extraConfig = lib.mkAfter (builtins.readFile "${dir}/tmux.conf");

  home.file.".config/tmux/bin/tmux-agent" = {
    source = "${dir}/tmux-agent";
    executable = true;
  };

  # Plain `tmux` opens the current folder's workspace (or goes back to it);
  # with arguments (`tmux ls`, `tmux a`, ...) it's the real tmux.
  programs.zsh.initContent = ''
    tmux() {
      if (( $# == 0 )); then ~/.config/tmux/bin/tmux-agent open "$PWD"
      else command tmux "$@"; fi
    }
  '';

  # Claude Code (and Gortex) write ~/.claude/settings.json themselves, so it
  # can't be a read-only link into the store. Merge our hooks in instead:
  # replaces only entries mentioning tmux-agent, keeps everything else, and
  # leaves the file alone when nothing would change. Running sessions pick the
  # hooks up on their next start.
  home.activation.claudeTmuxAgentHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    f="$HOME/.claude/settings.json"
    jq=${pkgs.jq}/bin/jq
    cur=$( [ -f "$f" ] && "$jq" . "$f" || echo '{}' )
    new=$(printf '%s' "$cur" | "$jq" --slurpfile kit ${dir}/claude-hooks.json '
      .hooks = reduce ($kit[0].hooks | to_entries[]) as $e (.hooks // {};
        .[$e.key] = [(.[$e.key] // [])[] | select(tostring | contains("tmux-agent") | not)] + $e.value)
    ') || new=
    if [ -z "$new" ]; then
      warnEcho "tmux-agents: could not merge Claude hooks into $f"
    elif [ "$new" != "$cur" ]; then
      run mkdir -p "$HOME/.claude"
      [ -f "$f" ] && run cp "$f" "$f.bak"
      tmp=$(mktemp)
      printf '%s\n' "$new" > "$tmp"
      run cp "$tmp" "$f"
      rm -f "$tmp"
    fi
  '';
}
