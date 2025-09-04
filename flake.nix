{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-config.url = "github:Goldan32/nix-home";
  };

  outputs = { self, nixpkgs, home-manager, home-config, ... }:
    let
      system = "x86_64-linux";

      mkHost = name: path:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            path
            ./modules/common.nix
            home-config.inputs.home-manager.nixosModules.home-manager {
              home-manager.users.goldan = home-config.outputs.homeConfigurations.goldan;
            }
          ];
        };
    in {
      nixosConfigurations = {
        vm = mkHost "vm" ./hosts/vm/configuration.nix;
      };
    };
}
