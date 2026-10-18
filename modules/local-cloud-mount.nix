{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.davfs2
  ];

  services.davfs2.enable = true;

  fileSystems."/mnt/server" = {
    device = "http://10.12.0.226:3923/";
    fsType = "davfs";

    options = [
      "noauto"
      "x-systemd.automount"
      "nofail"
      "_netdev"
      "rw"
      "uid=1000"
      "gid=100"
      "file_mode=0660"
      "dir_mode=0770"
    ];
  };

  users.groups.davfs2 = { };

  users.users.goldan = {
    extraGroups = [
      "davfs2"
    ];
  };

  systemd.tmpfiles.rules = [
    "L+ /home/goldan/server - - - - /mnt/server/personal/goldan"
  ];
}
