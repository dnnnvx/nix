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
  };

  outputs =
    inputs@{
      nix-darwin,
      home-manager,
      nix-homebrew,
      nixpkgs,
      ...
    }:
    let
      system = "aarch64-darwin";
      user = "marco";
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
              config.allowUnfree = true;
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

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
