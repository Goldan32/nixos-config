# Needed for mounting kindle
{ pkgs, ... }:
{
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.udev.packages = [ pkgs.libmtp ];

  environment.systemPackages = with pkgs; [
    libmtp
    go-mtpfs
  ];
}
