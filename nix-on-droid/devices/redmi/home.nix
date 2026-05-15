{
  pkgs,
  ...
}: {
  home = {
    stateVersion = "24.05";

    packages = with pkgs; [
      openssh
      ed
      gnugrep
      gnused
      gawk
      guile
      ghc
    ];
  };

  imports = [
    ../../shared/emacs-nox.nix
  ];
}
