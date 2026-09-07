# Plataforma exclusiva del Dell Inspiron 15 3520. No importar globalmente.
{ pkgs, ... }:

{
  imports = [
    ../../modules/system/extras-disk.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Early KMS de Intel para que Plymouth use la resolución nativa.
  boot.initrd.kernelModules = [ "i915" ];

  # Al bajar la tapa, hypridle bloquea la sesión y logind suspende el equipo.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
  };

  # Intel Iris Xe (Alder Lake): VA-API iHD y oneVPL/QSV.
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  # Firmware del WiFi/Bluetooth Realtek y microcode Intel.
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
}
