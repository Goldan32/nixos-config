{ config, lib, pkgs, ... }: {
  programs.sway = {
    enable = true;
      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export _JAVA_AWT_WM_NONREPARENTING=1
        export MOZ_ENABLE_WAYLAND=1
      '';
  };

  services.getty.autologinUser = "goldan"; # <-- change this

  environment.loginShellInit = ''
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec sway
    fi
  '';

  environment.systemPackages = with pkgs; [
    brightnessctl
    pavucontrol
  ];
}
