{
  description = "Marco's Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # master tracks nixpkgs-unstable; release branches pair with release nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    pi = {
      url = "github:earendil-works/pi/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    oh-my-pi = {
      url = "github:can1357/oh-my-pi";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stable, so `nix flake update nixpkgs` on the Mac doesn't redeploy the Pi
    nixpkgs-rpi.url = "github:NixOS/nixpkgs/nixos-26.05";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-rpi";
    };
  };

  outputs =
    inputs@{
      nix-darwin,
      home-manager,
      nix-homebrew,
      nixpkgs,
      nixpkgs-rpi,
      sops-nix,
      ...
    }:
    let
      system = "aarch64-darwin";
      user = "marco";

      mkRpi =
        host:
        nixpkgs-rpi.lib.nixosSystem {
          specialArgs = { inherit inputs user; };

          modules = [
            "${nixpkgs-rpi}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            sops-nix.nixosModules.sops
            ./systems/rpi
            host
            { nixpkgs.hostPlatform = "aarch64-linux"; }
          ];
        };
    in
    {
      darwinConfigurations.Marcos-MacBook-Pro = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs user; };

        modules = [
          ./systems/marco
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nixpkgs = {
              hostPlatform = system;
              config = {
                allowUnfree = true;
                # Radicle's node protocol is unencrypted and peer auth is spoofable, which only
                # breaks private repos; publish public ones only.
                # Exact version on purpose: a newer still-flagged release fails again and gets re-checked.
                permittedInsecurePackages = [ "radicle-node-1.10.3" ];
              };
            };

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = { inherit inputs; };
              users.${user} = import ./home-manager;
            };

            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              inherit user;
              autoMigrate = true;
            };
          }
        ];
      };

      # Deployed from the Mac: nixos-rebuild switch --flake .#<name> --target-host marco@<name>.local.casasulgorgo.net --sudo
      nixosConfigurations = {
        rpi-1 = mkRpi ./systems/rpi/hosts/rpi-1.nix;
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
