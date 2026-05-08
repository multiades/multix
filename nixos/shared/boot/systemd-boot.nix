# systemd-boot (formerly known as gummiboot) is a minimal UEFI bootloader, since UEFI can load .efi executables directly
{
  ...
}: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
