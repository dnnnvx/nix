# Nix config

Personal Apple Silicon Mac setup declared with [nix-darwin](https://github.com/LnL7/nix-darwin), [home-manager](https://github.com/nix-community/home-manager) and [nix-homebrew](https://github.com/zhaofengli/nix-homebrew).

## Structure

```
flake.nix             inputs and the Marcos-MacBook-Pro system
systems/marco/        system config: environment, Homebrew, SSH, macOS defaults
home-manager/         user packages
  programs/           per-program modules (git, helix, kubectl, zsh, ...)
  config/             raw config files (helix, omp)
```

## Commands

```sh
# Apply
sudo nix run nix-darwin -- switch --flake ~/.config/nix   # first install only
sudo darwin-rebuild switch --flake ~/.config/nix

# Check without activating
darwin-rebuild build --flake ~/.config/nix

# Update
nix flake update                # all inputs
nix flake update home-manager   # one input

# Roll back
darwin-rebuild --list-generations
sudo darwin-rebuild switch --rollback

# Maintain
nix fmt                         # format .nix files
sudo nix-collect-garbage -d     # delete old generations
```

Homebrew runs with `cleanup = "zap"`, so anything not listed in `systems/marco/settings/homebrew.nix` is removed on switch.
