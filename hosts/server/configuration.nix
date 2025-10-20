{ inputs, config, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "media-server";
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

