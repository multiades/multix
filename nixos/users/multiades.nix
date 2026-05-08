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
