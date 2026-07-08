{ config, pkgs, ... }:
{
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwK1g7Sq2gzGpDZgVs3AF8CFpDGF0N9Q="
    ];
  };

  time.timeZone = "Europe/Budapest";
  i18n.defaultLocale = "en_US.UTF-8";
  services.openssh.enable = true;
  virtualisation.docker.enable = true;

  users.users.goldan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "dialout" "docker" "disk" "power" ];
  };

  programs.zsh.enable = false;
  programs.neovim.enable = false;


  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.udev.packages = [ pkgs.libmtp ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    bash
    home-manager
    python3
    #pipx
    uv
    docker-compose
    docker-buildx
    wireguard-tools
    pulseaudio
    libmtp
    jmtpfs
  ];
}
