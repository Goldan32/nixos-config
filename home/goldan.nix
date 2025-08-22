{ config, pkgs, ... }:

{
  home.username = "goldan";
  home.homeDirectory = "/home/goldan";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    gcc
    stow
  ];

  home.stateVersion = "25.05";
}
