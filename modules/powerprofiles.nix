{ config, pkgs, ... }: {
  services.power-profiles-daemon.enable = true;
  environment.systemPackages = with pkgs; [
    power-profiles-daemon
  ];
}
