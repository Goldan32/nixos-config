{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core.nix
    ../../modules/docker.nix
    ../../modules/essential.nix
    ../../modules/cleanup.nix
    ../../modules/powerbutton.nix
    ../../modules/sway.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "media-server";

  system.stateVersion = "25.05";
}
