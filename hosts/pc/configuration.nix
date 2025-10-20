{ inputs, config, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/hyprland.nix
    ../../modules/nvidia.nix
    ../../modules/nfancurve.nix
    ../../modules/virtualization.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes"];

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

  # Keep only the last N generations in the menu
  # boot.loader.systemd-boot.configurationLimit = 10;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "pc";
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

