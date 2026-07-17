{ config, pkgs, ... }:
{
  imports = [
    ../../common/home.nix
  ];

  # Server-specific home config goes here as needed.
  # No polybar (KDE has its own panel), no autorandr (no xmonad).
}
