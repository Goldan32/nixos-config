{ config, lib, pkgs, ... }:

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

  programs.home-manager.enable = true;

  home.file.".zshrc" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/dotfiles/.zshrc";
  };

  home.activation.linkDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CURDIR="$(pwd)"
    cd "${config.home.homeDirectory}/nixos-config/dotfiles" && \
    ${pkgs.stow}/bin/stow --no-folding -t "$HOME" .
    cd "$CURDIR"
  '';

  home.stateVersion = "25.05";
}
