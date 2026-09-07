# Módulo "wayland/niri": compositor Wayland niri (scrollable-tiling).
# Cada compositor/servicio en su propia carpeta, como un crate.
#
# La configuración (config.kdl) se gestiona desde NixOS:
#   - Se instala en /etc/niri/config.kdl (fuente de verdad, versionada).
#   - Un tmpfiles rule crea ~/.config/niri/config.kdl como symlink a
#     /etc/niri/config.kdl (niri da prioridad al home, por eso el symlink).
# Edita el archivo config.kdl de este repo y corre `rebuild`.
{ config, lib, pkgs, ... }:

let
  defaultAccent = pkgs.writeText "niri-default-accent.kdl" ''
    layout {
        border {
            active-color "#5e81ac"
        }
    }
  '';

  # Convierte `niri validate` en una dependencia del sistema. La prueba usa
  # un HOME vacío y crea únicamente el archivo dinámico que tmpfiles garantiza,
  # por lo que detecta tanto errores KDL como includes ausentes en instalaciones
  # nuevas antes de que se pueda activar una generación rota.
  niriConfigCheck = pkgs.runCommand "niri-config-check" {
    nativeBuildInputs = [ pkgs.niri ];
  } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME/.config/niri"
    cp ${defaultAccent} "$HOME/.config/niri/accent.kdl"
    niri validate --config ${./config.kdl}
    touch "$out"
  '';
in

{
  programs.niri = {
    enable = true;
    # Parcheamos niri-session envolviendo el paquete con symlinkJoin para no recompilar niri desde código fuente.
    # Esto silencia el aviso de deprecación en stderr de `systemctl --user import-environment`.
    package = (pkgs.symlinkJoin {
      name = "niri-patched";
      paths = [ pkgs.niri ];
      postBuild = ''
        rm $out/bin/niri-session
        substitute ${pkgs.niri}/bin/niri-session $out/bin/niri-session \
          --replace-fail 'systemctl --user import-environment' 'systemctl --user import-environment PATH DBUS_SESSION_BUS_ADDRESS XDG_DATA_DIRS XDG_CONFIG_DIRS XDG_RUNTIME_DIR XAUTHORITY LANG LC_ALL LC_CTYPE 2>/dev/null'
        chmod +x $out/bin/niri-session
      '';
    }).overrideAttrs (oldAttrs: {
      passthru = (pkgs.niri.passthru or { }) // {
        providedSessions = pkgs.niri.providedSessions or [ "niri" ];
      };
    });
  };

  # Config gestionada por NixOS: niri la lee como fallback desde /etc/niri.
  environment.etc."niri/config.kdl".source = ./config.kdl;

  system.extraDependencies = [ niriConfigCheck ];

  # Fuerza que la config del home sea un symlink a la gestionada,
  # reemplazando el default que niri genera en el primer arranque.
  # Ruta absoluta: systemd no expande "~" en tmpfiles.
  systemd.tmpfiles.rules = [
    # En un home recién creado no existe ~/.config/niri. Debe declararse antes
    # de crear los archivos; confiar en que una sesión anterior lo haya creado
    # hacía que `niri validate` fallara en instalaciones limpias.
    "d /home/loonbac/.config/niri 0755 loonbac users -"
    "L+ /home/loonbac/.config/niri/config.kdl - - - - /etc/niri/config.kdl"
    # Acento dinámico: lo escribe accent-wallpaper. `C` copia el default
    # solamente si el destino no existe y permite usar un archivo multilínea
    # sin introducir líneas inválidas en la configuración de tmpfiles.
    "C /home/loonbac/.config/niri/accent.kdl 0644 loonbac users - ${defaultAccent}"
  ];
}
