{
  pkgs,
  ...
}: {
  home = {
    stateVersion = "24.05";

    packages = with pkgs; [
      openssh
      gnugrep
      guile
      ghc
    ];
  };

  imports = [
    ../../shared/emacs-nox.nix
  ];
}
