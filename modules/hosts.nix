{ config, pkgs, ... }:
{
  networking.hosts = {
    "10.12.0.226" = ["dnd.local"];
  };
}
