{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core.nix
    ../../modules/bluetooth.nix
    ../../modules/cleanup.nix
    ../../modules/docker.nix
    ../../modules/essential.nix
    ../../modules/hyprland.nix
    ../../modules/local-dns.nix
    ../../modules/mtp.nix
    ../../modules/nfancurve.nix
    ../../modules/nvidia.nix
    ../../modules/virtualization.nix
    ../../modules/wireguard.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 60;

  # Add Windows manually with a low sort-key so it's always first
  boot.loader.systemd-boot.extraEntries = {
    "windows.conf" = ''
      title   Windows Boot Manager
      efi     /EFI/Microsoft/Boot/bootmgfw.efi
      sort-key 00-windows
    '';
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "pc";

  system.stateVersion = "25.05";
}
