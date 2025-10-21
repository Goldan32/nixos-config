{ config, pkgs, ... }:
{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  boot.loader = {
    grub.configurationLimit = 50;
  };
}
