{ config, lib, ... }: {
  services.logind = {
    powerKey = "poweroff";
  };
}
