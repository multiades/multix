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
