{
  pkgs,
  ...
}: {
  home.packages = [(
    (pkgs.emacsPackagesFor pkgs.emacs-nox).emacsWithPackages
      (epkgs: with epkgs; [
        crdt 
      ])
  )];
}
