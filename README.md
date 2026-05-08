Most of us who have experienced the high of functional package managers can never go back. But there is a steep upfront cost for those to pay. Countless hours debugging functional source code and rewriting configurations. Hours which may very well be enjoyable but could have been allocated elsewhere.

Enter multix, an opinionated hub for generating Nix and Guix configurations with ease (currently only Nix).

The end goal for multix is to generate nixos, nix-darwin, nix-on-droid, nix-shells and home-manager configurations from a single opinionated interface (currently only providing nixos, nix-on-droid and home-manager configurations).

Users provide their desired packages and secrets, multix handles the rest via magic files and generates a full configuration with no boilerplate.

A graphical interface is due to be incorporated, aiming to ease the tension between the usefulness of a functional package manager and the barrier to entry even more.

Apart from `nixpkgs` and `home-manager`, a small project called [bibliothix](https://github.com/multiades/bibliothix) is used. It is a tiny, standalone library containing Nixlang auxiliary functions.

Multix uses flakes strictly. You should have the experimental features ["nix command", "flakes" ] enabled.

The nixos and home-manager sections use the `pipe-operators` experimental feature as well (which is not yet supported on nix-on-droid).


# Roadmap

-   handling secrets
-   web graphical interface; build your Nix store via dropdowns and uploaded snippets
-   nix-darwin support
-   nix-shells
-   Guix support


# Contributing

PRs are welcome. It is currenlty an early stage project.

