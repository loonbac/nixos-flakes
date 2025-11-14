{ config, pkgs, ...}:

{
    home.username = "loonbac";
    home.homeDirectory = "/home/loonbac";
    home.stateVersion = "25.05";

    # Permitir que home-manager gestione sí mismo
    programs.home-manager.enable = true;

    # Configuración de labwc
    home.file.".config/labwc" = {
      source = ./config/labwc;
      recursive = true;
    };
    # Configuración de kanshi (monitores)
    home.file.".config/kanshi" = {
      source = ./config/kanshi;
      recursive = true;
    };

    # Crear directorio para screenshots
    home.file."Pictures/.keep".text = "";

    programs.bash = {
        enable = true;
        shellAliases = {
            btw = "echo uso wayland btw";
            ll = "ls -lah";
            gs = "git status";
            rebuild = "sudo nixos-rebuild switch --impure --flake ~/nixos-flakes#bytewave";
        };
        initExtra = ''
            # Prompt personalizado
            PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        '';
    };

    # Asegurar que las aplicaciones Flatpak sean visibles en los lanzadores Wayland
    # Añadimos las rutas de exportación de Flatpak a XDG_DATA_DIRS en la sesión de usuario.
            home.sessionVariables = {
                # Incluir rutas estándar y las exportadas por Flatpak para que los lanzadores (rofi/wofi)
                # encuentren los archivos .desktop. Añadimos /run/current-system/sw/share porque NixOS
                # instala muchos recursos ahí.
                XDG_DATA_DIRS = "/run/current-system/sw/share:/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:${config.home.homeDirectory}/.local/share/flatpak/exports/share:${config.home.homeDirectory}/.local/share";
            };
}
