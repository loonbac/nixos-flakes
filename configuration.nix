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
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  users.users.loonbac = {
    isNormalUser = true;
    description = "Joshua Rosales";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };
  nixpkgs.config.allowUnfree = true;


  environment.systemPackages = with pkgs; [
    vim
    wget
    ghostty
    git
    tealdeer
    xclip
    bat
  ];

  system.stateVersion = "25.05"; # Did you read the comment?

}
