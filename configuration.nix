{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "bytewave";
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "America/Lima";
  i18n.defaultLocale = "es_PE.UTF-8";

  users.users.loonbac = {
    isNormalUser = true;
    description = "Joshua Rosales";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };
  nixpkgs.config.allowUnfree = true;

  # Optimizaciones AMD Ryzen 5700X
  hardware.cpu.amd.updateMicrocode = true;

  # Configuración GPU NVIDIA RTX 3060
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Para juegos de 32 bits
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # CRÍTICO: Habilitar DRM (Direct Rendering Manager) para Wayland
    # Esto es ESENCIAL para buen rendimiento en Wayland
    nvidiaPersistenced = true;
  };

#WAYLAND CON LABWC
  services.xserver.enable = false;
  programs.labwc.enable = true;

  # Pipewire para audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Portales XDG para Wayland
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
    # Preferir el portal para wlroots (labwc es wlroots-based)
    config.common.default = "wlr";
  };

  # Flatpak: habilitar servicio y paquetes útiles
  services.flatpak.enable = true;

  # Añadir repo Flathub automáticamente al arrancar el sistema (si aún no existe)
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
##################

  environment.systemPackages = with pkgs; [
    vim
    wget
    ghostty
    git
    bat
    fastfetch
    vscode
    firefox
    kdePackages.dolphin
    # Wayland y labwc
    labwc
    waybar
    wdisplays
    wlr-randr
    kanshi
    grim
    slurp
    rofi
    # Flatpak y utilidades para desarrollo/build
    flatpak
    flatpak-builder

    # Utilidades NVIDIA
    nvtopPackages.nvidia
  ];
  system.stateVersion = "25.05";
}
