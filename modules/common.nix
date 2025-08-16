{ config, pkgs, ... }:
{
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  services.openssh.enable = true;

  users.users.goldan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "dialout" "docker" ];
  };
}
