# Plataforma exclusiva de nixos-pc.
{ ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Muestra el selector NixOS/Windows; el resto de hosts conserva el arranque
  # directo definido por el módulo común.
  boot.loader.timeout = 5;

  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;

  # La RTX 3060 usa el driver NVIDIA con modulos de kernel abiertos. El modulo
  # de NixOS incorpora tambien nvidia-smi al PATH del sistema.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };
}
