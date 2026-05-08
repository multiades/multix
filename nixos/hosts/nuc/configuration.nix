{ 
  inputs,
  pkgs,
  bibliothix,
  ...
}: {
  # Instead of allowing all unfree packages for the system environment with config.allowUnfree = true, enable selected packages, this is just a permission specification, not an installation
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem
    (pkgs.lib.getName pkg)
    [
    ];

  environment = {
    systemPackages = with pkgs; [ # List desired environment packages
    ];

    # variables.EDITOR = "emacs"; Set the default editor (eg sudoedit)
  };

  system.stateVersion = "25.11"; # The first release of NixOS that was installed on this host, don't bump this without without caution, it concerns backward compatibility

  imports = bibliothix.path.withPath # The imports are functions, the module system calls them with the appropriate arguments, they can be sets iff they can be used statically, without arguments like pkgs
    ../../shared
    [ # Shared modules
      "boot/systemd-boot.nix" # At least one one the boot modules shall be present
      "xfce.nix"
      "el-locale.nix"
      "en-el-keyboard.nix"
      "core-networking.nix"
      "audio.nix"
      "ssh.nix"
      "laborg.nix"
    ]
  ++ bibliothix.path.withPath 
    ../../users
    [ # Users
      "guest.nix"
      "multiades.nix"
    ];
}
