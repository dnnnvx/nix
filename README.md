# Nix config

Personal Apple Silicon Mac setup declared with [nix-darwin](https://github.com/LnL7/nix-darwin), [home-manager](https://github.com/nix-community/home-manager) and [nix-homebrew](https://github.com/zhaofengli/nix-homebrew), plus NixOS Raspberry Pis deployed from the Mac.

## Structure

```
flake.nix             inputs and the Marcos-MacBook-Pro system
systems/marco/        system config: environment, Homebrew, SSH, macOS defaults
systems/rpi/          Raspberry Pis: shared base (SSH, Wi-Fi, nix settings)
  settings/           optional modules (mic stream for BirdNET-Go, BME280, ...)
  hosts/              one file per Pi: hostname and which settings it uses
.sops.yaml            who can decrypt each secrets file
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

## Raspberry Pi

The Mac builds each Pi's system with its Linux builder (`nix.linux-builder`) and copies it over SSH. The Pis never evaluate or compile anything, so even a 1 GB Pi is fine.

To add a Pi, copy `hosts/rpi-1.nix` with a new hostname and add it to `nixosConfigurations` in `flake.nix`. The examples below use `rpi-1`.

Each Pi has a static IP, `rpi.address` in its host file (`rpi-N` → `192.168.0.11N`, outside the router's DHCP pool), and a matching `rpi-N.local.casasulgorgo.net` record in the infra repo (tofu `local_hosts`). Leave `rpi.address` unset for DHCP.

```sh
# Deploy
nixos-rebuild switch --flake .#rpi-1 --target-host marco@rpi-1.local.casasulgorgo.net --sudo

# Try a change without touching the boot default; a reboot undoes it
nixos-rebuild test --flake .#rpi-1 --target-host marco@rpi-1.local.casasulgorgo.net --sudo

# Roll back
ssh marco@rpi-1.local.casasulgorgo.net sudo nixos-rebuild switch --rollback
```

### Flashing a new Pi

```sh
HOST=rpi-1

# Build the SD card image (compressed .img.zst)
nix build .#nixosConfigurations.$HOST.config.system.build.sdImage
nix shell nixpkgs#zstd -c zstd -d result/sd-image/*.img.zst -o $HOME/Downloads/$HOST.img

# Find the card (by its size)
diskutil list
DISK=disk4
diskutil unmountDisk /dev/$DISK
sudo dd if=$HOME/Downloads/$HOST.img of=/dev/r$DISK bs=4M status=progress

# macOS then mounts the card's FIRMWARE partition (replug the card if not): give the Pi the age key
cp ~/.config/sops/age/keys.txt /Volumes/FIRMWARE/sops-age.key
diskutil eject /dev/$DISK
rm $HOME/Downloads/$HOST.img
```

The first boot expands the filesystem and joins Wi-Fi in a minute or two; then `ssh marco@$HOST.local.casasulgorgo.net`.

### Wi-Fi

The Wi-Fi name and password are encrypted in `systems/rpi/secrets.yaml`, shared by all Pis. Each Pi decrypts them with the Mac's age key, `~/.config/sops/age/keys.txt` (also used by infra), copied to the SD card's `FIRMWARE` partition.

```sh
# Create or edit the secrets; sops opens your editor
sops systems/rpi/secrets.yaml
```

With this content:

```yaml
wifi: |
  WIFI_SSID=your-network
  WIFI_PSK=your-password
```

### Mic stream

The Pi only captures the mic and serves it as `rtsp://rpi-1.local.casasulgorgo.net:8554/mic`; BirdNET-Go runs on the cluster and reads that stream. The Pi keeps no state, so reflashing loses nothing.

```sh
# Find the mic's name, then set it as `device` in systems/rpi/settings/mic-stream.nix
ssh marco@rpi-1.local.casasulgorgo.net arecord -l

# Listen from the Mac
nix shell nixpkgs#ffmpeg -c ffplay -rtsp_transport tcp rtsp://rpi-1.local.casasulgorgo.net:8554/mic
```

### BME280

Wired to the GPIO header (VIN pin 1, GND pin 6, SDA pin 3, SCL pin 5). The Pi serves its readings as JSON on `http://rpi-1.local.casasulgorgo.net:9280`, for Home Assistant's REST integration:

```sh
curl http://rpi-1.local.casasulgorgo.net:9280
# {"temperature": 21.43, "humidity": 48.12, "pressure": 1013.25}

# If it answers 503: check the wiring and address (76 or 77)
ssh marco@rpi-1.local.casasulgorgo.net 'sudo i2cdetect -l; journalctl -u bme280'
```

Homebrew runs with `cleanup = "zap"`, so anything not listed in `systems/marco/settings/homebrew.nix` is removed on switch.
