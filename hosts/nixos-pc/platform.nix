# Plataforma exclusiva de nixos-pc. El primer despliegue conserva nouveau;
# el driver NVIDIA propietario se habilitará después de validar el arranque.
{ ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Muestra el selector NixOS/Windows; el resto de hosts conserva el arranque
  # directo definido por el módulo común.
  boot.loader.timeout = 5;

  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nouveau" ];
}
