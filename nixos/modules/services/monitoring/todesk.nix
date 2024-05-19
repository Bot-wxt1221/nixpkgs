{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.todesk;

in

{

  ###### interface
 options = {

    services.todesk.enable = mkEnableOption "ToDesk daemon";

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
      preStart = "mkdir -pv /var/lib/todesk&&cp ${pkgs.todesk}/opt/todesk/bin/ToDesk_Service /var/lib/todesk";
      serviceConfig = {
        Type = "simple";
	Environment = "LIBVA_DRIVER_NAME=iHD LIBVA_DRIVERS_PATH=${pkgs.todesk}/opt/todesk/bin";
        ExecStart = "/var/lib/ToDesk_Service";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGINT $MAINPID";
        Restart = "on-failure";
	User = cfg.user;
      };
    };
  };

}
