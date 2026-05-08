
# Table of Contents

1.  [Pinning](#org2060e14)
2.  [nixos](#orgdee5d4c)
    1.  [Hosts](#orgdfe6f4f)
    2.  [Users](#org17acf21)
    3.  [Shared system modules](#org821e0af)
3.  [home-manager](#orgdd3d549)
    1.  [Users](#org2a65573)
    2.  [Shared user modules](#orgf63d075)
4.  [nix-on-droid](#org9ab3478)
    1.  [Devices](#org1df0d53)
    2.  [Shared droid modules](#org433eba6)


<a id="org2060e14"></a>

# Pinning

A standard flake file is used for the version pinning. Add any inputs of your choice in it. They are inherited across the flake tree, so they can be referenced in any module.

    
    {
      description = "An opinionated Nix configuration hub called multix";
    
      inputs = {
        bibliothix.url = "github:multiades/bibliothix"; # A tiny, standalone Nixlang library
    
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    
        nixpkgs-droid.url = "github:NixOS/nixpkgs/nixos-24.05"; # nix-on-droid lags behind latest stable revision
    
        home-manager = {
          url = "github:nix-community/home-manager/release-25.11";
          inputs.nixpkgs.follows = "nixpkgs"; # Use the same git revision as `nixpkgs` pinned above for the home-manager's own flake `nixpkgs` input, so you don't end up with two different nixpkgs versions in your system
        };
    
        home-manager-droid = {
          url = "github:nix-community/home-manager/release-24.05";
          inputs.nixpkgs.follows = "nixpkgs-droid";
        };
    
        nix-on-droid = {
          url = "github:nix-community/nix-on-droid/release-24.05";
          inputs.nixpkgs.follows = "nixpkgs-droid";
          inputs.home-manager.follows = "home-manager-droid";
        };
      };
    
      outputs = inputs: {
        nixosConfigurations = builtins.import
          ./nixos/hosts # Each host is a subdirectory in there (/nixos/hosts/<hostname>/) containing the respective hardware-configuration.nix and configuration.nix
          {
            inherit inputs;
          };
    
        homeConfigurations = builtins.import 
          ./home-manager/users # Each user is a nix file in there (/home-manager/users/<username>.nix)
          {
            inherit inputs;
          };
    
        nixOnDroidConfigurations = builtins.import
          ./nix-on-droid/devices # Each device is a subdirectory containing `configuration.nix` and `home.nix` files (hardware configurations are handled by the native OS and each devices wrap a single non-system user, no point in having home-manager separated, Android acts as the system and nix-on-droid as the user)
          {
            inherit inputs;
          };
      };
    }


<a id="orgdee5d4c"></a>

# nixos


<a id="orgdfe6f4f"></a>

## Hosts

The directory `/nixos/hosts/` regards the various host configurations available via the flake.

The file `/nixos/hosts/default.nix` acts as the host aggregator, providing a template for all host configurations. We shall document it piece by piece.

The following snippet declares the file's expression as a unary function with an attribute set argument, exposing `inputs` as one of that argument's attributes. It also binds the imported expression (another attribute set) of the `bibliothix` input a constant of the same name.

    
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

Add any host formatted as a `/nixos/hosts/<hostname>/` directory.
Each one should contain the desired host's auto-generated `hardware-configuration.nix` file and a provided `configuration.nix` file.

NOTE: The following block should not be included in the documentation.

    
    # Do not modify this file!  It was generated by ‘nixos-generate-config’ and may be overwritten by future invocations.
    { 
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }: {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];
    
      boot = {
        initrd = {
          availableKernelModules = [
            "ahci" 
            "xhci_pci"
            "usbhid"
            "usb_storage"
            "sd_mod"
            "sdhci_acpi"
          ];
          
          kernelModules = [
          ];
        };
        
        kernelModules = [
          "kvm-intel"
        ];
        
        extraModulePackages = [
        ];
      };
      
      fileSystems = {
        "/" = { 
          device = "/dev/disk/by-uuid/38224afa-74ce-41e4-9216-c87539f96526";
          fsType = "ext4";
        };
    
        "/boot" = {
          device = "/dev/disk/by-uuid/8F3E-D0F3";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };
      };
    
      swapDevices = [
      ];
    
      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking (the default) this is the recommended approach. When using systemd-networkd it's still possible to use this option, but it's recommended to use it in conjunction with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      networking.useDHCP = lib.mkDefault true;
      # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
      # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;
    
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    }

Here is the **nuc's** `configuration.nix` file:

    
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


<a id="org17acf21"></a>

## Users

Top-level user configurations (host-independent) can be declared as nix files in `/nixos/users/`.
<span class="underline">Note</span>: it is recommended to configure system options strictly via nixos and leave the users' home configurations up to home-manager.

An example of a **guest** user with a non-persistent home directory:

    
    { 
      ...
    }: {
      users.users.guest = {
        isNormalUser = true;
    
        description = "guest";
    
        password = ""; # Empty password field in /etc/shadow
    
        extraGroups = [ # Accesses nothing
        ];
    
        packages = [
        ];
      };
    
      # No persistent home directory
      fileSystems."/home/guest" = {
        device = "tmpfs"; # Temporary filesystem, stored in volatile memory (RAM)
    
        fsType = "tmpfs";
    
        options = [ 
          "size=1G" # Temporary files' size cap, all guest files are written in RAM, the whole RAM is available for other tasks
    
          "mode=777" # Readable and writable by everyone
        ];
      };
    }

An example of a named user (in this case multiades, passwords are provided as hashes for now):

    
    {
      ...
    } : {
      users.users.multiades = { 
        isNormalUser = true;
    
        description = "multiades"; # A comment/label which is displayed on the login screen of the display manager
    
        extraGroups = [ # Sound/audio groups are obsolete with pipewire
          "wheel"
        ];
    
        # hashedPassword = "<hash>";
    
        openssh.authorizedKeys.keys = [ # SSH authentication happens on user level
          # <hash>
        ];
    
        packages = [ # We can list user-specific packages here, but home-manager allows dotfile management
        ];
      };
    }


<a id="org821e0af"></a>

## Shared system modules

Shared system modules are stored in the `/nixos/shared/` directory. There is a `boot` subdirectory which features three boot options (systemd-boot, grub-bios and grub-uefi), of which exactly one should be imported in the finalized system configuration.

The three boot modules:

    
    # systemd-boot (formerly known as gummiboot) is a minimal UEFI bootloader, since UEFI can load .efi executables directly
    {
      ...
    }: {
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    }

    
    { 
      ...
    }: {
      boot.loader = {
        grub = {
          device = "nodev"; # GRUB does not alter the MBR
          efiSupport = true; # Whether GRUB should be built with EFI support, false by default
        };
    
        efi.canTouchEfiVariables = true;
      };
    }

    
    { 
      ...
    } : {
      bootloader.grub.enable = true;
      # For grub's device use per-host by-id hardcoded paths, in UEFI machines this path is provided in hardware-configuration.nix
    }

Other shared system modules:

    
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

    
    {
      pkgs,
      ...
    }: {
      services = {
        xserver = {
          enable = true; # Enable X11 window manager daemon
          displayManager.lightdm.enable = true; # LightDM display manager, login screen
          desktopManager.xfce.enable = true; # XFCE desktop manager
        };
          
        gvfs.enable = true; # GTK-based file managers like thunar depend on it
      };
      
      programs.nm-applet.enable = true; # Enable network applet, so as to not only interact with networking via CLI, false by default
    
      environment.systemPackages = with pkgs; [
        ntfs3g # Helper driver for thunar
      ] ++ (with pkgs.xfce; [ # The following packages are not mandatory for the xfce desktop manager and can be also be added per use instead
        thunar # XFCE's file manager
        thunar-volman # XFCE's volume manager (handles automounts etc.)
      ]);
    }

    
    {
      ...
    }: {
      time.timeZone = "Europe/Athens";
    
      i18n = { # Internationalisation properties
        supportedLocales = [ # All locales available (formatting and UI but not keyboard languages)
          "en_US.UTF-8/UTF-8" 
          "el_GR.UTF-8/UTF-8"
        ];
         
        defaultLocale = "en_US.UTF-8";
    
        extraLocaleSettings = let extra = "el_GR.UTF-8"; 
        in { # Use some components of a supported extra locale
          LC_ADDRESS = extra;
          LC_IDENTIFICATION = extra; 
          LC_MEASUREMENT = extra;
          LC_MONETARY = extra; 
          LC_NAME = extra; 
          LC_NUMERIC = extra;
          LC_PAPER = extra;
          LC_TELEPHONE = extra;
          LC_TIME = extra;
        };
      };
    }

    
    {
      ...
    }: {
      services.xserver.xkb = { # Configure key mapping in X11
        layout = "us, gr"; # Layouts in order
        options = "grp:win_space_toggle"; # Keyboard language toggle keybinding
      };
    
      console.useXkbConfig = true; # Synchronize the keyboard layout of the graphical environment with the text consoles (TTYs - Teletypewriters)
    }

    
    {
      ...
    }: {
      networking = {
        firewall = {
          enable = true;
          
          allowedTCPPorts = [
          ];
    
          allowedUDPPorts = [
          ];
        };
    
        networkmanager.enable = true; # Enable networking (all of it is done via network manager, even WiFi support), don't set the option useDHCP, network manager handles that internally
    
        wireless.enable = false; # Disable wireless support via wpa_supplicant so as not to clash with network manager
      };
    }

    
    {
      ...
    }: {
      services.pipewire = { # Pipewire, the modern sound option
        enable = true; # Initialize the pipewire daemon
    
        alsa = { # Pipewire's ALSA compatibility layer, for apps which use it directly
          enable = true;
    
          support32Bit = true; # Needed for 32-bit software, eg Wine, Steam and some old closed-source programs
        };
    
        pulse.enable = true; # Provides PulseAudio-compatible server for some apps, pipewire emulates it
      };
    
      security.rtkit.enable = true; # Enable the Real-Time kit for managing real-time scheduling for audio applications
    }

    
    {
      ...
    }: {
      services.openssh = {
        enable = true; # Enable the openssh daemon
    
        settings = { # Only allow key access and deny superuser access
          PasswordAuthentication = false;
    
          KbdInteractiveAuthentication = false;
    
          PermitRootLogin = "no";
        };
      };
    }


<a id="orgdd3d549"></a>

# home-manager

Every home-manager configuration is of the format <username>@<architecture>.
The username should match one provided by the system configuration.


<a id="org2a65573"></a>

## Users

    
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

An example of a user file (in this case the username is multiades):

    
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


<a id="orgf63d075"></a>

## Shared user modules

A python build for data analysis and machine learning:

    
    { 
      pkgs,
      ...
    }: {
      home.packages = [(pkgs.python313.withPackages
       (pyPkgs: with pyPkgs; [ # Build a single python derivation with the following packages baked-in and have HM use thatp
         numpy
         pandas
         openpyxl # For XLSX file parsing in pandas
         matplotlib
         tkinter # The GUI backend for plotting
         scikit-learn
         xgboost
         tensorflow
       ])
      )];
    }

An emacs module example:

    
    {
      inputs,
      pkgs,
      ...
    }: {
      programs.emacs = {
        enable = true;
    
        extraPackages = (epkgs: with epkgs; [ # Wrap the Emacs executable so all package-provided binaries are on exec-path, needed for epdfinfo
          # org is preinstalled in emacs since version 22.2
          org-roam
          org-roam-ui # Graphical front-end for org-roam
          ob-nix # Org Babel/Nix backend, not by default in org-babel, like ob-haskell
          pdf-tools # PDF viewer, better than the native DocView
          geiser-guile # ob-scheme uses geiser as its backend
          crdt 
        ]);
      };
    }


<a id="org9ab3478"></a>

# nix-on-droid


<a id="org1df0d53"></a>

## Devices

    
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

Environment packages are moot, since we are on Android using home-manager.
Example of a device (called redmi):

    
    {
    ...
    }: {
      time.timeZone = "Europe/Athens";
    }

    
    {
      pkgs,
      ...
    }: {
      home = {
        stateVersion = "24.05";
    
        packages = with pkgs; [
          openssh
          gnugrep
          guile
          ghc
        ];
      };
    
      imports = [
        ../../shared/emacs-nox.nix
      ];
    }


<a id="org433eba6"></a>

## Shared droid modules

    
    {
      pkgs,
      ...
    }: {
      home.packages = [(
        (pkgs.emacsPackagesFor pkgs.emacs-nox).emacsWithPackages
          (epkgs: with epkgs; [
            crdt 
          ])
      )];
    }

