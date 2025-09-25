{ config, pkgs, ... }:
{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Limit how many old system generations are kept
  boot.loader = {
    grub.configurationLimit = 10;
  };
}
