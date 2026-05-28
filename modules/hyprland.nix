{ config, pkgs, inputs, ... }:
{
  services.displayManager.ly.enable = true;

  imports = [ inputs.hyprland.nixosModules.default ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [
    inputs.hy3.packages.${pkgs.system}.default
    brightnessctl
    pavucontrol
    hyprlock
  ];
}
