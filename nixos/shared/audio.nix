{
  ...
}: {
  services.pipewire = { # Pipewire, the modern sound option
    enable = true; # Initialize the pipewire daemon

    alsa = { # Pipewire's ALSA compatibility layer, for apps which use it directly
      enable = true;

      support32Bit = true; # Needed for 32-bit software, eg Wine, Steam and some old closed-source programs
    };

    pulse.enable = true; # Provides PulseAudio-compatible server for some apps, pipewire emulates it
  };

  security.rtkit.enable = true; # Enable the Real-Time kit for managing real-time scheduling for audio applications
}
