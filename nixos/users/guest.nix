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
