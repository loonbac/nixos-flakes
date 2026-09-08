# Steam moddeable mediante Millennium. El modulo queda registrado globalmente,
# pero solo se activa en los hosts que habiliten loon.programs.steam.enable.
{ config, lib, pkgs, millennium, ... }:

let
  cfg = config.loon.programs.steam;
in
{
  options.loon.programs.steam.enable = lib.mkEnableOption
    "Steam con el framework de temas y plugins Millennium";

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ millennium.overlays.default ];

    programs.steam = {
      enable = true;
      package = pkgs.millennium-steam;
    };
  };
}
