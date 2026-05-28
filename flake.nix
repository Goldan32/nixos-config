{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-config.url = "path:./home";

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.54.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hy3 = {
      url = "github:outfoxxed/hy3/hl0.54.2";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = { self, nixpkgs, home-manager, home-config, ... }@inputs:
    let
      system = "x86_64-linux";

      mkHost = name: path: hmModule:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            path
            ./modules/common.nix
            home-manager.nixosModules.home-manager

            ({ ... }: {
              home-manager.users.goldan = {
                imports = [ hmModule ];
                _module.args.jotter = home-config.inputs.jotter;
                _module.args.zen-browser = home-config.inputs.zen-browser;
                _module.args.system = system;
                _module.args.dotfiles = home-config.inputs.dotfiles;
              };
            })
          ];
        };
    in {
      nixosConfigurations = {
        vm = mkHost "vm" ./hosts/vm/configuration.nix home-config.hmModules.goldan;
        zenbook = mkHost "zenbook" ./hosts/zenbook/configuration.nix home-config.hmModules.goldan;
        pc = mkHost "pc" ./hosts/pc/configuration.nix home-config.hmModules.goldan;
        server = mkHost "server" ./hosts/server/configuration.nix home-config.hmModules.headless;
      };
    };
}
