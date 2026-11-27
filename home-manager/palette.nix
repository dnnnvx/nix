# One color palette for ghostty, tmux and nvim.
# Surfaces come from NvChad's radium (base46); text and accents from GitHub Dark Dimmed,
# so code looks like Zed. Change a value here and rebuild: every program reading it follows.
# tmux.conf refers to these as {{name}} (filled in by tmux-agents.nix).
{
  # surfaces (radium, one step darker), darkest to lightest
  bg-inset = "#050709"; # unfocused tmux panes, nvim floats
  bg = "#0a0d11";
  bg-raised = "#121519"; # status bar, messages
  selection = "#23262a";
  border = "#26262e";

  # text (GitHub Dark Dimmed), brightest to dimmest; fg-subtle is radium's grey
  fg = "#adbac7";
  white = "#909dab";
  fg-muted = "#768390"; # comments
  fg-subtle = "#525559"; # dim text (terminal bright black)

  # accents (GitHub Dark Dimmed)
  red = "#f47067";
  red-bright = "#ff938a";
  orange = "#f69d50";
  yellow = "#c69026";
  yellow-bright = "#daaa3f";
  green = "#57ab5a";
  green-bright = "#6bc46d";
  blue = "#539bf5";
  blue-bright = "#6cb6ff";
  purple = "#b083f0";
  purple-bright = "#dcbdfb";
  cyan = "#76e3ea";
  cyan-bright = "#b3f0ff";
}
