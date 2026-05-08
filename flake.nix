{
  description = "An opinionated Nix configuration hub called multix";

  inputs = {
    bibliothix.url = "github:multiades/bibliothix"; # A tiny, standalone Nixlang library

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixpkgs-droid.url = "github:NixOS/nixpkgs/nixos-24.05"; # nix-on-droid lags behind latest stable revision

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same git revision as `nixpkgs` pinned above for the home-manager's own flake `nixpkgs` input, so you don't end up with two different nixpkgs versions in your system
    };

    home-manager-droid = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-droid";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-droid";
      inputs.home-manager.follows = "home-manager-droid";
    };
  };

  outputs = inputs: {
    nixosConfigurations = builtins.import
      ./nixos/hosts # Each host is a subdirectory in there (/nixos/hosts/<hostname>/) containing the respective hardware-configuration.nix and configuration.nix
      {
        inherit inputs;
      };

    homeConfigurations = builtins.import 
      ./home-manager/users # Each user is a nix file in there (/home-manager/users/<username>.nix)
      {
        inherit inputs;
      };

    nixOnDroidConfigurations = builtins.import
      ./nix-on-droid/devices # Each device is a subdirectory containing `configuration.nix` and `home.nix` files (hardware configurations are handled by the native OS and each devices wrap a single non-system user, no point in having home-manager separated, Android acts as the system and nix-on-droid as the user)
      {
        inherit inputs;
      };
  };
}
