{ config, lib, pkgs, ... }:

let

  cfg = config.services.rustdesk;

in

{

  options = {

    services.rustdesk.enable = lib.mkEnableOption "Rustdesk daemon";

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.rustdesk ];

    systemd.services.rustdesk = {
      enable = true;
      description = "rustdesk";
      serviceConfig = {
        ExecStart = "${pkgs.rustdesk}/bin/rustdesk --service";
        ExecStop = "pkill -f \"rustdesk --\"";
        PIDFile = "/run/rustdesk.pid";
        KillMode = "mixed";
        TimeoutStopSec = "30";
        User = "root";
        LimitNOFILE = "100000";
      };
      wantedBy = [ "multi-user.target" ];
      requires = ["network-online.target"];
      after = ["display-manager.service"];
    };
  };

}
