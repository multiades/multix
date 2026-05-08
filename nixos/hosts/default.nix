{
  inputs,
  ...
}: let 
  bibliothix = builtins.import inputs.bibliothix;

  mkHost = { # Applied on a host attribute set
    basename, # Destructuring names, should match exactly with bibliothix.path.fileSearch's set pattern attributes, since it is used in the definition
    path
  }: inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { 
      inherit inputs bibliothix;
    };
 
    modules = [ # Standard modules for all hosts (all except the inline one are dynamic for each host)
      (path + "/hardware-configuration.nix")

      (path + "/configuration.nix")

      { # Inline module
        boot.supportedFilesystems = [
          "ntfs"
          "exfat"
          "vfat"
        ];

        nix.settings.experimental-features = [ # Experimental features available, subject to change in the future
          "nix-command"
          "flakes"
          "pipe-operators" # I like them, only use in nixos and home-manager
        ]; 

        networking.hostName = basename;

        services.udisks2.enable = true; # udisks2 is a disk management daemon, used for automounting and other stuff

        # Set Git commit hash for nixos-version using fallbacks (clean git repo, dirty git repo - uncommited changes, no git repo)
        # system.configurationRevision = self.rev or self.dirtyRev or null;

        # Why is the following file not able to be linked in nix store upon rebuilding?
        environment.etc."nixos/README".text = ''
          This machine is managed via multix.
          Do not edit configurations here; changes will have no effect.
        '';
       
        users = { 
          mutableUsers = false; # Disable imperative user management
    
          users.root.password = "!"; # Unix convention for existent but locked (disabled) accounts, if set to null (default) it will produce "!" in /etc/shadow but it may allow passwordless login, depending on PAM configuration
        };
      }
    ];
  };

in
  {
    root = ./.;
    filetype = "directory";
    suffix = "";
  }
  |> bibliothix.path.fileSearch
  |> builtins.map 
    (hostSet: {
      name = hostSet.basename;
      value = mkHost hostSet;
    })
  |> builtins.listToAttrs # Collapse the attribute set list into an attribute set, which is what nixosConfigurations expects
