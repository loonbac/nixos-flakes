# Plataforma exclusiva de nixos-pc. El primer despliegue conserva nouveau;
# el driver NVIDIA propietario se habilitará después de validar el arranque.
{ ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nouveau" ];
}
