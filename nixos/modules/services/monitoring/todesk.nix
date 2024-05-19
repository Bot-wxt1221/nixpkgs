{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.todesk;

in

{

  ###### interface
 options = {

    services.todesk.enable = mkEnableOption "ToDesk daemon";
    services.todesk.user = mkOption {description = "Todesk daemon user";type=types.str;};

  };

  ###### implementation

  config = mkIf (cfg.enable) {

    environment.systemPackages = [ pkgs.todesk ];

    systemd.services.todeskd = {
      description = "ToDesk Daemon Service";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" "nss-lookup.target" ];
      after = [ "network-online.target" ];
      before = [ "nss-lookup.target" ];
      requires = [ "dbus.service" ];
      preStart = "mkdir -pv /opt/todesk&&cp -rf ${pkgs.todesk}/opt/todesk/* /opt/todesk";
      serviceConfig = {
        Type = "simple";
	Environment = "LIBVA_DRIVER_NAME=iHD LIBVA_DRIVERS_PATH=${pkgs.todesk}/opt/todesk/bin Tuser=${cfg.user}";
        ExecStart = "bash ${pkgs.todesk}/opt/todesk/start.sh";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGINT $MAINPID";
        Restart = "on-failure";
	User = "root";
      };
    };
  };

}
