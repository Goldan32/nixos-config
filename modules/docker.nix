{ pkgs, ... }:
{
  virtualization.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
    docker-buildx
  ];
}
