{
  ...
}: {
  services.xserver.xkb = { # Configure key mapping in X11
    layout = "us, gr"; # Layouts in order
    options = "grp:alt_shift_toggle"; # Toggler hotkey (cycle through layouts), Alt + Shift is older than the Super + Space toggle
  };

  console.useXkbConfig = true; # Synchronize the keyboard layout of the graphical environment with the text consoles (TTYs - Teletypewriters)
}
