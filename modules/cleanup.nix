{ ... }:
{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  boot.loader = {
    grub.configurationLimit = 30;
    systemd-boot.configurationLimit = 30;
  };
}
