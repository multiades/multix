# A fileshare server based on org mode
{ 
  pkgs,
  ...
}: {
  systemd = {
    services.laborg = { 
      description = "laborg collaborative server"; # Label which shows up in systemctl status and journal logs

      wantedBy = [ 
        "multi-user.target" # systemd should start this service when the system reaches multi-user mode (the normal running state of a headless Linux server), without this the service exists but never starts automatically
      ];

      after = [ # Ordering declaration
        "network.target" # Start this service only after the network is up, crdt.el binds to a port
      ];
    
      serviceConfig = { # Configure how systemd actually runs the process
        User = "laborer"; # Run the service as an isolated system user instead of the superuser, this is a safety feature

        ExecStart = let # The command systemd runs on starting the process
          emacs = (pkgs.emacsPackagesFor pkgs.emacs-nox).emacsWithPackages # Build it in or cache it via the nix store, emacs-nox drops the GUI toolkit dependency
            (epkgs: with epkgs; [
              # org is built in
              crdt # Emacs confict-free replicated data types implementation
            ]);
        in 
          "${emacs}/bin/emacs --fg-daemon --init-directory /var/lib/laborer/.config/emacs"; # --fg-daemon starts Emacs as --daemon but stays in the foreground so systemd can track the process correctly, the --init-directory flag dictates the location of the emacs configuration, preventing the auto creation of .emacs.d

        Restart = "on-failure"; # systemd should restart the process automatically upon crashing (not on clean exit)

        RestartSec = "5s"; # systemd should wait five seconds before restarting after a failure, preventing a rapid crash loop from hammering the system
      };
    };

    tmpfiles.rules = [ # Created files via systemd
      "d /var/lib/prolet/.config 0755 laborer laborers -"
      "d /var/lib/laborer/.config/emacs 0755 laborer laborers -"
    ];
  };

  # Since this user is tied to this service, it is created in the current nixos module
  users = {
    groups.laborers = { # Create the (empty) laborers group
    }; 

    users.laborer = {
      isSystemUser = true; # UID below 1000, cannot login interactively, provides a service
      group = "laborers"; # Primary group, every user belongs to one
      extraGroups = [
      ];
      home = "/var/lib/laborer"; # Conventional UNIX location for service data, this option is just metadata
      createHome = true; # Actually create the desired home directory
    };
  };
}
