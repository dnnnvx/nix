# Personal skills/agents for coding agents: a private git repo checked out at
# ~/Documents/Projects/skills. It's a normal writable checkout: edit, commit
# and push there yourself; edits are live immediately, a new skill needs one
# rebuild to get its link.
#   - cloned on activation when missing, never pulled afterwards
#   - each skills/<name> is linked into ~/.agents/skills (the cross-tool
#     location pi, Codex & co. read) and ~/.claude/skills (Claude Code only
#     reads its own folder); each agents/<name>.md into ~/.claude/agents;
#     AGENTS.md becomes ~/.claude/CLAUDE.md (personal instructions)
#   - per-item links, so whatever else lives there (skills other tools
#     install) is left alone; our links whose target was removed from the
#     repo get cleaned up
{ lib, pkgs, ... }:
let
  repo = "git@github.com:dnnnvx/skills.git";
in
{
  home.activation.agentsRepo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dir="$HOME/Documents/Projects/skills"

    if [ ! -e "$dir" ]; then
      # never hang on a passphrase/host-key prompt during a rebuild
      export GIT_SSH_COMMAND="/usr/bin/ssh -o BatchMode=yes -o ConnectTimeout=5"
      run ${pkgs.git}/bin/git clone --recurse-submodules ${repo} "$dir" \
        || warnEcho "agents: could not clone ${repo} into $dir, clone it by hand"
      unset GIT_SSH_COMMAND
    fi

    # link_one <source> <target>: create or retarget our link, never clobber
    # a file that isn't ours
    link_one() {
      local s="$1" t="$2"
      if [ ! -e "$t" ] && [ ! -L "$t" ]; then
        run ln -s "$s" "$t"
      elif [ -L "$t" ] && case "$(readlink "$t")" in "$dir"/*) true ;; *) false ;; esac; then
        [ "$(readlink "$t")" = "$s" ] || run ln -sfn "$s" "$t"
      else
        warnEcho "agents: $t already exists and isn't ours, skipping"
      fi
    }

    # link_into <repo subfolder> <target folder>
    link_into() {
      local src="$dir/$1" dst="$2" l s
      run mkdir -p "$dst"
      # remove our links whose target is gone
      for l in "$dst"/*; do
        [ -L "$l" ] && [ ! -e "$l" ] || continue
        case "$(readlink "$l")" in "$dir"/*) run rm "$l" ;; esac
      done
      [ -d "$src" ] || return 0
      for s in "$src"/*; do
        [ -e "$s" ] || continue
        link_one "$s" "$dst/$(basename "$s")"
      done
    }
    link_into skills "$HOME/.agents/skills"
    link_into skills "$HOME/.claude/skills"
    link_into agents "$HOME/.claude/agents"
    if [ -e "$dir/AGENTS.md" ]; then
      link_one "$dir/AGENTS.md" "$HOME/.claude/CLAUDE.md"
    fi
  '';
}
