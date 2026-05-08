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
