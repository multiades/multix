{ 
  ...
} : {
  bootloader.grub.enable = true;
  # For grub's device use per-host by-id hardcoded paths, in UEFI machines this path is provided in hardware-configuration.nix
}
