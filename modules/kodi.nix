{ pkgs, ... }:
let
  kodiPkg = pkgs.kodi-wayland.passthru.withPackages (p: with p; [ jellycon ]);
in
{
  environment.systemPackages = [ kodiPkg ];

  systemd.user.services.kodi = {
    description = "Kodi";
    serviceConfig = {
      ExecStart = "${kodiPkg}/bin/kodi";
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
