{
  inputs,
  ...
}: let
  bibliothix = builtins.import inputs.bibliothix;

  supportedArchitectures = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  mkPkgs = {
    origin, # The origin package set is mandatorily an instantiation of nixpkgs, due to the use of stdenv
    prospectNames ? []
  }: builtins.foldl' # More efficient than bibliothix's foldr, since it is a builtin and evaluates eagerly (trivial side-effect: it reverses the list)
    (acc: prospectName: let
      prospect = origin.${prospectName} or null; # Return null if the key does not exist instead of throwing, 'or' is the safe access operator, not the Boolean OR (||)
    in if
      prospect == null || !(builtins.tryEval prospect.meta.available).value # tryEval is necessary here because meta.available can itself throw during evaluation
      then builtins.trace # Provide a warning and resume execution
        "the package associated with the name '${prospectName}' is either non-existent, broken or unsupported, for the working architecture, skipping it!"
        acc
      else [ prospect ] ++ acc)
    []
    prospectNames;

  mkHome = { # The first two attributes of the argument are named like the ones returned by helpers.path.fileSearch
    basename,
    path,
    architecture
  }: inputs.home-manager.lib.homeManagerConfiguration { 
    pkgs = builtins.import 
      inputs.nixpkgs 
      {
        system = architecture; # The system option is baked in and accessible in the modules below this point in the filetree
      };
     
    modules = [
      path # User specific module

      { 
        programs.home-manager.enable = true; # Enable the home-manager command across all users to rebuild home configurations

        home = {
          username = basename;

          homeDirectory = "/home/${basename}"; # Needed for home-manager to place some hidden files, the system's option just sets where the login home is, home-manager runs independently

          stateVersion = "25.11"; # Mirroring NixOS' state version
        };
      }
    ];

    extraSpecialArgs = { # Passed in each module
      inherit inputs bibliothix mkPkgs;
    };
  };

in
  {
    root = ./.;
    filetype = "regular";
    suffix = "nix";
  }
  |> bibliothix.path.fileSearch
  |> builtins.filter (set:
    set.basename != "default") # Skip default.nix's set 
  |> builtins.map (userSet: builtins.map # Cross-product of all supported architectures and all users
    (architecture: {
      name  = "${userSet.basename}@${architecture}";
      value = mkHome { 
        basename = userSet.basename;
        path = userSet.path;
        inherit architecture;
      };
    })
    supportedArchitectures)        
  |> builtins.concatLists
  |> builtins.listToAttrs
