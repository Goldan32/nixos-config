{ ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Europe/Budapest";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  users.users.goldan = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "dialout"
      "docker"
      "disk"
      "power"
    ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
}
