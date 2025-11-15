{ config, pkgs, ...}:

{
    home.username = "loonbac";
    home.homeDirectory = "/home/loonbac";
    home.stateVersion = "25.05";

    programs.home-manager.enable = true;

    programs.bash = {
        enable = true;
        shellAliases = {
            btw = "echo uso Nix-OS btw";
            ll = "ls -lah";
            gs = "git status";
            rebuild = "sudo nixos-rebuild switch --impure --flake ~/nixos-flakes#bytewave";
        };
        initExtra = ''
            # Prompt personalizado
            PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        '';
    };
}
