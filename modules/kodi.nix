# kodi.nix — installs Kodi with the Jellyfin add-on bundled in.
{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.kodi.withPackages (p: with p; [
      jellyfin
    ]))
  ];
}
