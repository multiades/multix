{
  pkgs,
  bibliothix,
  mkPkgs,
  ... 
}: {
  imports = bibliothix.path.withPath
    ../../shared
    [ # Shared modules (filenames or directories)
      "python.nix"
      "emacs.nix"
    ];

  # Declare a list of allowed unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem 
    (pkgs.lib.getName pkg) 
    [
      "discord"
    ];

  # Declare user's level miscellaneous packages (non declarative dotfile configuration, later transition to programs.enable.<program>)
  home.packages = mkPkgs {
    origin = pkgs;
    prospectNames = [
      "openssh" # Just the client, the server belongs in the NixOS config, if at all
      "firefox"
      "git"
      "guile" # GNU scheme interpreter
      "ghc"
      # "curl"
      # "wget"
      "sct"
      "gimp"
      "libreoffice"
      "zip"
      "unzip"
      "discord"
      # "element-desktop", provider for matrix rooms, transition to ement.el later
    ];
  };
}
