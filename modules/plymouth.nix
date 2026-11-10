{ ... }: {
  boot.plymouth = {
    enable = true;
    theme = "spinner";
  };

  hardware.nvidia.modesetting.enable = true;

  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  boot.consoleLogLevel = 3;

  boot.kernelParams = [
    "quiet"
    "splash"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=auto"
  ];
}
