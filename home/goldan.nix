{ config, pkgs, ... }:

{
  home.username = "goldan";
  home.homeDirectory = "/home/goldan";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    gcc
    stow
    ripgrep
    tree
  ];

  home.file.".zshrc" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/dotfiles/.zshrc";
  };

  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
}
