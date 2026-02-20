{ config, pkgs, ... }:
{
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
    pipx
    uv
    docker-compose
    docker-buildx
    wireguard-tools
    pulseaudio
    libmtp
    jmtpfs
  ];
}
