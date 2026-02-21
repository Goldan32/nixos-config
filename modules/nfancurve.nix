{ config, pkgs, lib, ... }:
let
  nfancurvePkg = pkgs.stdenv.mkDerivation {
    pname = "nfancurve";
    version = "0.1.0";
    src = pkgs.fetchgit {
      url = "https://github.com/Goldan32/nfancurve.git";
      rev = "e4abc021ec0e6d6819c60063a397634b297548d0";
      sha256 = "sha256-IxxBn2uD2h5P6kAtOL77oSsVgwH4wOyVTgBYHdfCB/8=";
    };

    installPhase = ''
      mkdir -p $out/bin
      cp $src/temp.sh $out/bin/nfancurve.sh
      chmod +x $out/bin/nfancurve.sh
    '';
  };

  nfancurveConfigFile = pkgs.writeText "nfancurve.conf" ''
    # min_t is the temperature at which every temperature below it will cause
    #  the fan speed to be set to 0%, and everything above will be whatever the
    #  first speed in fcurve is (default of 25%)
    # min_t2 is only used with the second fan speed and temperature arrays, so
    #  there is no need to change it unless you're using the second curve
    min_t="38"
    min_t2="25"
    
    # How many seconds the script should wait until checking for a change in temps
    sleep_time="7"
    
    hyst="5"
    
    # By default it's set up so that when the temp is less than or equal to 35
    #  degrees, the fan speed will be set to 25%. Next, if the temp is between 36
    #  and 45, the fan speed should be set to 40%, etc.
    # The last temperature value will be the maximum temperature before 100% fan
    #  speed will be set
    # You can make the array as big or as small as you require, as long as they
    #  both end up being the same size
    fcurve="0 30 60 70 85" # fan speeds
    tcurve="39 45 55 65 75" # temperatures
    
    # This value is used to determine the temperature difference needed to get
    #  the script to check for a new speed to apply. The default of this value
    #  is zero, which means the script will automatically calculate a value
    #  based on the temperature curves supplied below
    force_check="2"
    
    # These two arrays are for GPU's that have a secondary fan that you may wish
    #  to control seperately, especially if it is water-cooled.
    fcurve2="15 30 45 60 75"
    tcurve2="35 45 55 65 75"
    
    # First number in array is fan 0, second number is fan 1, etc. If the number
    #  is 1, that indicates that the script should use the first curve for that
    #  fan. The same goes for the number 2.
    which_curve="1 1 1"
    
    # Only used for single-fan operation. If you have more than one gpu/fan but
    #  only want to control one of them, select which one here. Otherwise there
    #  is no need to change this setting.
    default_fan="0"
    
    # Similar to which_curve, but instead lets the script know which of the GPU's
    #  has which fan. i.e. element 0 in the array being set to 0 means that fan 0
    #  is assigned to GPU 0, element 1 is 0 too, meaning fan 1 is on GPU 0 as well
    fan2gpu="0 0 1 1"
  '';
in {
  systemd.services.xhostToRoot = {
    description = "Allow root to start nvidia-setttings";
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      Type = "simple";
      User = "goldan";
      After = "graphical.target";
      Environment = [ "DISPLAY=:0" ];
      ExecStart = "${pkgs.xhost}/bin/xhost si:localuser:root";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };

  systemd.services.nfancurve = {
    description = "nfancurve service";
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      Type = "simple";
      After = "xhostToRoot.service";
      Environment = [
        "PATH=/run/current-system/sw/bin:/run/wrappers/bin"
        "DISPLAY=:0"
      ];
      ExecStart = "${nfancurvePkg}/bin/nfancurve.sh -c ${nfancurveConfigFile}";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };
}

