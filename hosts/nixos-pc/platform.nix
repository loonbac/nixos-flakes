# Plataforma exclusiva de nixos-pc.
{ pkgs, ... }:

let
  ddcBrightness = pkgs.callPackage ../../pkgs/ddc-brightness {
    monitorModel = "GM3CC236";
  };
in
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Muestra el selector NixOS/Windows; el resto de hosts conserva el arranque
  # directo definido por el módulo común.
  boot.loader.timeout = 5;

  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;

  # Los monitores externos no exponen /sys/class/backlight. DDC/CI viaja por
  # los buses I2C de la NVIDIA; este backend controla el monitor principal
  # GM3CC236 conectado a DP-2 y alimenta el indicador de Waybar.
  hardware.i2c.enable = true;
  users.users.loonbac.extraGroups = [ "i2c" ];
  environment.systemPackages = [
    pkgs.ddcutil
    ddcBrightness
  ];

  # Un único proceso conserva el estado, agrupa ráfagas de input y evita que
  # cada paso de la rueda bloquee esperando varios intercambios DDC.
  systemd.user.services.ddc-brightness = {
    description = "Control de brillo DDC/CI del monitor principal";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session-pre.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${ddcBrightness}/bin/ddc-brightness daemon";
      Restart = "on-failure";
      RestartSec = "1s";
      RuntimeDirectory = "ddc-brightness";
      RuntimeDirectoryMode = "0700";
    };
  };

  # La RTX 3060 usa el driver NVIDIA con modulos de kernel abiertos. El modulo
  # de NixOS incorpora tambien nvidia-smi al PATH del sistema.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };
}
