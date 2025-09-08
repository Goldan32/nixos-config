{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-config.url = "github:Goldan32/nix-home/?rev=b157b5f855d3b50f85ed909518a2ff53e71f20f0";
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
            home-manager.nixosModules.home-manager

            ({ ... }: {
              home-manager.users.goldan = {
                imports = [ home-config.hmModules.goldan ];
                _module.args.jotter = home-config.inputs.jotter;
                _module.args.system = system;
              };
            })
          ];
        };
    in {
      nixosConfigurations = {
        vm = mkHost "vm" ./hosts/vm/configuration.nix;
        zenbook = mkHost "zenbook" ./hosts/zenbook/configuration.nix;
      };
    };
}
