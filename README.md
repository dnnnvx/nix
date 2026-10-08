```sh
nix build .#darwinConfigurations.Marcos-MacBook-Pro.system
./result/sw/bin/darwin-rebuild switch --flake .
# or
darwin-rebuild switch --flake ~/.config/nix
# or
nix run nix-darwin -- switch --flake .
```
