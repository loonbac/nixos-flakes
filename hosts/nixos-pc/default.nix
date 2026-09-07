# Host de escritorio ASRock B550 Pro4 (Ryzen 7 5700X + NVIDIA).
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./platform.nix
  ];

  networking.hostName = "nixos-pc";
  system.stateVersion = "26.05";
}
