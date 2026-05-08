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
