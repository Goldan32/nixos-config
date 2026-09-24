{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core.nix
    ../../modules/essential.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.05";
}
