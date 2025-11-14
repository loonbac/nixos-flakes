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
    packages = with pkgs; [];
  };
  nixpkgs.config.allowUnfree = true;

#WAYLAND CON LABWC
  services.xserver.enable = false;
  programs.labwc.enable = true;
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };
##################

  environment.systemPackages = with pkgs; [
    vim
    wget
    ghostty
    git
    tealdeer
    xclip
    bat
    alacritty
    fastfetch
    vscode
    firefox

    labwc
    waybar
    foot
    wlr-randr
    kanshi
    grim
    slurp
  ];

  system.stateVersion = "25.05"; # Did you read the comment?

}
