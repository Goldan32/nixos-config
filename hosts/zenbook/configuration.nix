{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/bluetooth.nix
    ../../modules/core.nix
    ../../modules/cleanup.nix
    ../../modules/docker.nix
    ../../modules/essential.nix
    ../../modules/hyprland.nix
    ../../modules/local-dns.nix
    ../../modules/powerbutton.nix
    ../../modules/powerprofiles.nix
    ../../modules/tailscale.nix
    ../../modules/wireguard.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "zenbook";

  system.stateVersion = "25.05";
}
