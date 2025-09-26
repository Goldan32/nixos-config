{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/hyprland.nix
    ../../modules/cleanup.nix
    ../../modules/bluetooth.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes"];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "zenbook";
  networking.networkmanager.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  networking.firewall.enable = false;

  system.stateVersion = "25.05";
}

