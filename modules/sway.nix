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

  services.getty.autologinUser = "goldan";

  environment.loginShellInit = ''
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec sway
    fi
  '';

  environment.systemPackages = with pkgs; [
    brightnessctl
    pavucontrol
  ];

  system.activationScripts.swayReload = {
    text = ''
      user="goldan"
      uid=$(${pkgs.util-linux}/bin/runuser -u "$user" -- id -u)
      sock="/run/user/''${uid}/sway-ipc.''${uid}.$(${pkgs.util-linux}/bin/runuser -u "$user" -- ${pkgs.procps}/bin/pgrep -x sway).sock"

      if [ -S "$sock" ]; then
        ${pkgs.util-linux}/bin/runuser -u "$user" -- env SWAYSOCK="$sock" ${pkgs.sway}/bin/swaymsg reload || true
      fi
    '';
    deps = [ ];
  };
}
