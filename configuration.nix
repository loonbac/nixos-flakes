{ config, pkgs, ... }:

{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
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
    nvidiaPersistenced = true;
  };

  # COSMIC Desktop Environment
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
  # Enable XWayland support in COSMIC
  services.desktopManager.cosmic.xwayland.enable = true;

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
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
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

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    fastfetch
    vscode
    
    # Flatpak
    flatpak
    flatpak-builder

    # Utilidades NVIDIA
    nvtopPackages.nvidia
  ];

  # Montaje del disco para juegos
  fileSystems."/home/loonbac/Juegos" = {
    device = "UUID=cd03ab63-a704-4005-8670-2232af672439";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  system.stateVersion = "25.05";
}
