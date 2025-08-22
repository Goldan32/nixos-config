{ config, pkgs, ... }:
{
  time.timeZone = "Europe/Budapest";
  i18n.defaultLocale = "en_US.UTF-8";
  services.openssh.enable = true;

  users.users.goldan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "dialout" "docker" ];
  };

  programs.zsh.enable = true;
  programs.neovim.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    zip
    xz
    unzip
    file
    which
    gnused
    gnutar
    gawk
    gnupg
    bash
    fd
    home-manager
  ];
}
