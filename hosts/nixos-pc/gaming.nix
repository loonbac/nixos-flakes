# Aplicaciones de juegos exclusivas del PC de escritorio.
{ pkgs, ... }:

{
  loon.programs.steam = {
    enable = true;
    spaceThemeFix.enable = true;
  };

  environment.systemPackages = [
    pkgs.heroic
  ];
}
