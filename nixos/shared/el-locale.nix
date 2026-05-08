{
  ...
}: {
  time.timeZone = "Europe/Athens";

  i18n = { # Internationalisation properties
    supportedLocales = [ # All locales available (formatting and UI but not keyboard languages)
      "en_US.UTF-8/UTF-8" 
      "el_GR.UTF-8/UTF-8"
    ];
     
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = let extra = "el_GR.UTF-8"; 
    in { # Use some components of a supported extra locale
      LC_ADDRESS = extra;
      LC_IDENTIFICATION = extra; 
      LC_MEASUREMENT = extra;
      LC_MONETARY = extra; 
      LC_NAME = extra; 
      LC_NUMERIC = extra;
      LC_PAPER = extra;
      LC_TELEPHONE = extra;
      LC_TIME = extra;
    };
  };
}
