# Control de brillo DDC/CI para el monitor principal de nixos-pc.
{ pkgs, monitorModel }:

pkgs.writeShellApplication {
  name = "ddc-brightness";
  runtimeInputs = with pkgs; [
    coreutils
    ddcutil
    gawk
    procps
    util-linux
  ];
  text = ''
    set -euo pipefail

    command="''${1:-get}"
    monitor_model=${builtins.toJSON monitorModel}
    runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}"
    lock_file="$runtime_dir/ddc-brightness.lock"
    bus_cache="$runtime_dir/ddc-brightness.bus"

    exec 9>"$lock_file"
    if ! flock --wait 5 9; then
      echo "ddc-brightness: el monitor está ocupado" >&2
      exit 1
    fi

    detect_bus() {
      local output bus
      output="$(ddcutil detect --brief 2>/dev/null)" || return 1
      bus="$(printf '%s\n' "$output" | awk -v model="$monitor_model" '
        /I2C bus:/ { bus = $NF }
        /Monitor:/ && index($0, ":" model ":") {
          sub(".*/i2c-", "", bus)
          print bus
          exit
        }
      ')"
      case "$bus" in
        ""|*[!0-9]*) return 1 ;;
      esac
      [ -c "/dev/i2c-$bus" ] || return 1
      printf '%s\n' "$bus" > "$bus_cache"
      printf '%s\n' "$bus"
    }

    select_bus() {
      local bus=""
      [ -f "$bus_cache" ] && bus="$(cat "$bus_cache" 2>/dev/null || true)"
      case "$bus" in
        ""|*[!0-9]*) detect_bus; return ;;
      esac
      if [ -c "/dev/i2c-$bus" ]; then
        printf '%s\n' "$bus"
      else
        detect_bus
      fi
    }

    read_vcp() {
      local output values
      output="$("''${ddc[@]}" --terse getvcp 10 2>/dev/null)" || return 1
      values="$(printf '%s\n' "$output" | awk '
        $1 == "VCP" && toupper($2) == "10" && $3 == "C" {
          print $4, $5
          exit
        }
      ')"
      [ -n "$values" ] || return 1
      printf '%s\n' "$values"
    }

    unavailable() {
      if [ "$command" = json ]; then
        printf '%s\n' '{"text":"", "percentage":0, "alt":"unavailable", "tooltip":"Brillo DDC no disponible"}'
        exit 0
      fi
      echo "ddc-brightness: no se pudo leer DDC/CI del monitor $monitor_model" >&2
      exit 1
    }

    bus="$(select_bus)" || unavailable
    ddc=(ddcutil --bus="$bus" --sleep-multiplier=.1)

    if ! values="$(read_vcp)"; then
      # El número de bus puede cambiar tras modificar conexiones. Redetectar
      # una vez evita dejar guardado un destino obsoleto.
      rm -f "$bus_cache"
      bus="$(select_bus)" || unavailable
      ddc=(ddcutil --bus="$bus" --sleep-multiplier=.1)
      values="$(read_vcp)" || unavailable
    fi
    read -r current_raw max_raw <<< "$values"
    case "$current_raw:$max_raw" in
      *[!0-9:]*) unavailable ;;
    esac
    [ "$max_raw" -gt 0 ] || unavailable

    raw_to_ui() {
      local raw="$1"
      local percent=$(( (raw * 100 + (max_raw / 2)) / max_raw ))
      [ "$percent" -le 100 ] || percent=100
      printf '%s\n' "$percent"
    }

    normalize_ui() {
      local percent="''${1:-}"
      percent="''${percent%%%}"
      case "$percent" in
        ""|*[!0-9]*)
          echo "ddc-brightness: el brillo debe ser un número entre 0 y 100" >&2
          return 1
          ;;
      esac
      [ "$percent" -le 100 ] || {
        echo "ddc-brightness: el brillo debe estar entre 0 y 100" >&2
        return 1
      }
      printf '%s\n' "$percent"
    }

    set_ui() {
      local percent target_raw
      percent="$(normalize_ui "$1")" || return 1
      target_raw=$(( (percent * max_raw + 50) / 100 ))
      "''${ddc[@]}" setvcp 10 "$target_raw" >/dev/null
      pkill -RTMIN+8 waybar 2>/dev/null || true
    }

    current_ui="$(raw_to_ui "$current_raw")"
    case "$command" in
      get)
        printf '%s\n' "$current_ui"
        ;;
      set)
        set_ui "''${2:-}"
        ;;
      up|+)
        step="$(normalize_ui "''${2:-10}")" || exit 1
        target=$(( current_ui + step ))
        [ "$target" -le 100 ] || target=100
        set_ui "$target"
        ;;
      down|-)
        step="$(normalize_ui "''${2:-10}")" || exit 1
        target=$(( current_ui - step ))
        [ "$target" -ge 0 ] || target=0
        set_ui "$target"
        ;;
      json)
        if [ "$current_ui" -ge 65 ]; then
          alt=high
        elif [ "$current_ui" -ge 30 ]; then
          alt=medium
        else
          alt=low
        fi
        printf '{"text":"%s%%", "percentage":%s, "alt":"%s", "tooltip":"Brillo del monitor: %s%%"}\n' \
          "$current_ui" "$current_ui" "$alt" "$current_ui"
        ;;
      *)
        echo "Uso: ddc-brightness [get|set <0..100>|up [paso]|down [paso]|json]" >&2
        exit 2
        ;;
    esac
  '';
}
