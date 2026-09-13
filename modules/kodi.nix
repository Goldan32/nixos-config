{ pkgs, ... }:
let
  kodiPkg = pkgs.kodi.withPackages (p: with p; [ jellycon ]);
in
{
  environment.systemPackages = [ kodiPkg ];

  systemd.user.services.kodi = {
    description = "Kodi";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${kodiPkg}/bin/kodi --standalone";
      Restart = "on-failure";
    };
  };
}
