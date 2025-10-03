{ config, pkgs, ... }: {
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  nixpkgs.config.allowUnfree = true;

  hardware.graphics = {
    enable = true;
  };

  # Enable NVIDIA modesetting
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false; # Experimental
    open = false; # Use proprietary driver
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";   # VAAPI acceleration
    GBM_BACKEND = "nvidia-drm";     # Use DRM backend
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";  # Avoids cursor glitches
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
  };

  services.xserver.deviceSection = ''
    Option "Coolbits" "4"
  '';

  environment.systemPackages = with pkgs; [
    vulkan-tools
    vulkan-validation-layers
    libva
    libva-utils
    lm_sensors
    linuxKernel.packages.linux_xanmod_stable.asus-ec-sensors
  ];
}

