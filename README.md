# Nix config

[nix-darwin](https://github.com/LnL7/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager) flake for personal Mac setup (Apple Silicon, `aarch64-darwin`).

## Layout

| Path | Purpose |
| --- | --- |
| `flake.nix` | Inputs (nixpkgs-unstable, nix-darwin, home-manager, nix-homebrew, pi, oh-my-pi) and the `darwinConfigurations` output |
| `systems/marco/` | System-level (nix-darwin) config: environment, Homebrew, SSH, macOS defaults |
| `home-manager/` | User-level config: packages and per-program modules in `programs/` (git, helix, ssh, starship, tmux, zed, zsh) |

## Usage

First install (`darwin-rebuild` isn't on the PATH yet):

```sh
nix run nix-darwin -- switch --flake ~/.config/nix
```

Afterwards:

```sh
darwin-rebuild switch --flake ~/.config/nix
```

Build without activating (output lands in `./result`), useful to check that the config evaluates:

```sh
nix build .#darwinConfigurations.Marcos-MacBook-Pro.system
```

Other handy commands:

```sh
nix flake update                 # bump all inputs (rewrites flake.lock)
nix flake update home-manager    # bump a single input
nix fmt                          # format all .nix files (nixfmt-tree)
darwin-rebuild --list-generations
darwin-rebuild switch --rollback # go back to the previous generation
```
