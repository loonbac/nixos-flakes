# Comando custom `nixos-ssh`: toggle de autenticación del servidor SSH.
#
# Pregunta si se quiere autenticar por contraseña o por clave (cert),
# escribe el modo en modules/services/openssh/ssh-auth-mode y aplica la
# configuración NixOS con el mismo nixos-rebuild que el comando `rebuild`.
#
# Uso:
#   nixos-ssh      # menú interactivo: password | cert | cancelar
{ pkgs, lib }:

let
  script = pkgs.writeShellScriptBin "nixos-ssh" ''
    set -euo pipefail

    FLAKE_DIR="$HOME/.nixos"
    HOST="''${NIXOS_HOST:-$(< /proc/sys/kernel/hostname)}"
    STATE_FILE="$FLAKE_DIR/modules/services/openssh/ssh-auth-mode"

    case "$HOST" in
      ""|*[!A-Za-z0-9_-]*)
        echo "Hostname no válido para seleccionar el flake: '$HOST'" >&2
        exit 1
        ;;
    esac

    configured_host="$(${pkgs.nix}/bin/nix eval --raw \
      "$FLAKE_DIR#nixosConfigurations.$HOST.config.networking.hostName" 2>/dev/null)" || {
      echo "El flake no contiene nixosConfigurations.$HOST" >&2
      exit 1
    }
    if [[ "$configured_host" != "$HOST" ]]; then
      echo "La configuración '$HOST' declara el hostname '$configured_host'." >&2
      exit 1
    fi

    # Si no existe el archivo de estado, lo crea con el modo seguro (cert).
    if [[ ! -f "$STATE_FILE" ]]; then
      echo "No se encontró ssh-auth-mode; creando con modo 'cert' (seguro)." >&2
      echo "cert" > "$STATE_FILE"
    fi

    current="$(cat "$STATE_FILE" | tr -d '[:space:]')"
    echo "Servidor SSH: $HOST"
    echo "Modo actual:  $current"
    echo

    PS3="Modo de autenticación SSH (1=password, 2=cert, 3=cancelar): "
    select mode in password cert cancelar; do
      case "$mode" in
        password|cert) break ;;
        cancelar) echo "Sin cambios."; exit 0 ;;
        *) echo "Opción inválida." ;;
      esac
    done

    if [[ "$mode" == "$current" ]]; then
      echo "El servidor ya está en modo '$mode'. Sin cambios."
      exit 0
    fi

    echo "$mode" > "$STATE_FILE"
    echo "Aplicando modo '$mode' al flake ($FLAKE_DIR)..."

    if ! (cd "$FLAKE_DIR" && sudo nixos-rebuild switch --flake ".#$HOST"); then
      echo "$current" > "$STATE_FILE"
      echo "El rebuild falló; se revirtió el modo a '$current'." >&2
      exit 1
    fi

    echo
    echo "SSH ahora en modo '$mode'."
    if [[ "$mode" == "password" ]]; then
      echo "Admitirá contraseña. (PermitRootLogin sigue en 'no'.)"
    else
      echo "Solo por clave/certificado (contraseñas desactivadas)."
    fi
  '';
in
script
