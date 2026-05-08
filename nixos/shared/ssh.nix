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
