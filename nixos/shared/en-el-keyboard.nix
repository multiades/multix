{
  ...
}: {
  services.xserver.xkb = { # Configure key mapping in X11
    layout = "us, gr"; # Layouts in order
    options = "grp:win_space_toggle"; # Keyboard language toggle keybinding
  };

  console.useXkbConfig = true; # Synchronize the keyboard layout of the graphical environment with the text consoles (TTYs - Teletypewriters)
}
