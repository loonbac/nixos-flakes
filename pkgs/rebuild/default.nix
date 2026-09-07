# Comando custom `rebuild`: reconstruye la configuración de NixOS
# del host actual usando el flake local (~/.nixos).
# Equivalente al "cargo build && cargo run" del proyecto.
#
# Uso:
#   rebuild            # aplica los cambios (nixos-rebuild switch)
#   rebuild dry        # prueba sin aplicar
#   rebuild update     # actualiza nixpkgs y aplica
{ pkgs, lib }:

let
  script = pkgs.writeShellScriptBin "rebuild" ''
    set -euo pipefail

    FLAKE_DIR="$HOME/.nixos"
    HOST="''${NIXOS_HOST:-$(< /proc/sys/kernel/hostname)}"

    cd "$FLAKE_DIR"

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

    case "''${1:-switch}" in
      dry)
        sudo nixos-rebuild dry-run --flake ".#$HOST"
        ;;
      update)
        nix flake update
        sudo nixos-rebuild switch --flake ".#$HOST"
        ;;
      switch)
        sudo nixos-rebuild switch --flake ".#$HOST"
        ;;
      *)
        echo "Uso: rebuild [switch|dry|update]" >&2
        exit 1
        ;;
    esac
  '';
in
script
