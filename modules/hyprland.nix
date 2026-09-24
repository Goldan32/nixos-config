{ pkgs, inputs, ... }:
{
  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwK1g7Sq2gzGpDZgVs3AF8CFpDGF0N9Q="
    ];
  };

  services.displayManager.ly.enable = true;

  imports = [ inputs.hyprland.nixosModules.default ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [
    inputs.hy3.packages.${pkgs.stdenv.hostPlatform.system}.default
    hyprlock
    hyprpaper
  ];
}
