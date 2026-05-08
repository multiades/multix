{
  inputs,
  ...
}: let 
  bibliothix = builtins.import inputs.bibliothix;

  mkDev = { 
    basename,
    path
  }: inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    # Set nixpkgs instance for nix-on-droid, it is only supported for aarch64-linux systems
    pkgs = builtins.import
      inputs.nixpkgs-droid
      { 
        system = "aarch64-linux"; 
      };

    # Set home-manager's path
    home-manager-path = inputs.home-manager-droid.outPath;

    modules = [
      (path + "/configuration.nix")

      {
        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';

        environment.etcBackupExtension = ".bak"; # Backup etc files instead of failing to activate generation if a file already exists in `/etc`

        # Read the changelog before changing this value
        system.stateVersion = "24.05";
   
        # Configure home-manager
        home-manager = {
          useGlobalPkgs = true; # Because how else will this refer to pkgs? The top-level attribute set is not recursive.
          backupFileExtension = "hm-bak";
          config = path + "/home.nix";
        };
      }
    ];

    # extraSpecialArgs = ...
  };

in bibliothix.list.pipe 
  {
    root = ./.;
    filetype = "directory";
    suffix = "";
  }
  [
    bibliothix.path.fileSearch

    (builtins.map (devSet: {
      name = devSet.basename;
      value = mkDev devSet;
    }))

    builtins.listToAttrs
  ]
