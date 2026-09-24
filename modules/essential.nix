{ pkgs, ... }:
{

  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    bash
    home-manager
    python3
    pulseaudio
  ];
}
