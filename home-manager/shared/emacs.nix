{
  inputs,
  pkgs,
  ...
}: {
  programs.emacs = {
    enable = true;

    extraPackages = (epkgs: with epkgs; [ # Wrap the Emacs executable so all package-provided binaries are on exec-path, needed for epdfinfo
      # org is preinstalled in emacs since version 22.2
      org-roam
      org-roam-ui # Graphical front-end for org-roam
      ob-nix # Org Babel/Nix backend, not by default in org-babel, like ob-haskell
      pdf-tools # PDF viewer, better than the native DocView
      geiser-guile # ob-scheme uses geiser as its backend
      crdt 
    ]);
  };
}
