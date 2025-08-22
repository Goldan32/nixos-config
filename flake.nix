{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }:
    let
      system = "x86_64-linux";

      mkHost = name: path:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            path
            ./modules/common.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.goldan = import ./home/goldan.nix;
            }
          ];
        };
    in {
      nixosConfigurations = {
        vm = mkHost "vm" ./hosts/vm/configuration.nix;
      };
    };
}
