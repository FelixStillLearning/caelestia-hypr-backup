#!/usr/bin/env bash
# Menu pilih audio output & input (F11), gaya Caelestia.
# Perangkat yang port-nya tidak tersambung (mis. jack kosong) disembunyikan.
~/.local/bin/sync-caelestia-rofi.py

ext_display=0
grep -qx connected /sys/class/drm/card*-{HDMI,DP}-*/status 2>/dev/null && ext_display=1

# Nama ramah + ikon Material Symbols. Masukan: "name port" description
pretty() {
    local name=$1 desc=$2
    case $name in
        bluez_*)            echo "$desc|Bluetooth|bluetooth" ;;
        *Headphones*|*analog-output-headphones*)       echo "Headphones|Audio jack|headphones" ;;
        *Speaker*|*analog-output-speaker*)          echo "Laptop Speakers|Built-in|speaker" ;;
        *Mic1*|*internal-mic*)             echo "Laptop Microphone|Built-in|mic" ;;
        *Mic2*|*Headset*|*analog-input-mic*)   echo "Headset Microphone|Audio jack|headset_mic" ;;
        *pci-0000_05_00.1*) echo "HDMI / DisplayPort ${name##*-}|External display|tv" ;;
        *)                  echo "$desc|${name%%.*}|${3:-speaker}" ;;
    esac
}

def_sink=$(pactl get-default-sink) def_src=$(pactl get-default-source)
names=() kinds=() rows=() metas=() active=() sel=0 n=0

header() { rows+=("$1"); metas+=($'nonselectable\x1ftrue'); names+=(""); kinds+=(""); n=$((n+1)); }
item() {  # kind name title sub icon
    local color=on-surface-variant
    if [[ $2 == "$def_sink" || $2 == "$def_src" ]]; then color=primary; active+=("$n"); fi
    [[ $2 == "$def_sink" ]] && sel=$n
    rows+=("$3"$'\n'"<span size='small' alpha='65%'>$4</span>")
    metas+=($'icon\x1f'"$(~/.local/bin/rofi-icon "$5" "$color")")
    names+=("$2"); kinds+=("$1"); n=$((n+1))
}

header "<span size='small' alpha='65%'>OUTPUT</span>"
while IFS=$'\t' read -r name desc port; do
    [[ $name == *pci-0000_05_00.1* && $ext_display == 0 ]] && continue
    IFS='|' read -r t s i <<<"$(pretty "$name $port" "$desc")"
    item sink "$name" "$t" "$s" "$i"
done < <(pactl -f json list sinks | jq -r '.[] | . as $d | (.ports // []) as $p | select(([$p[] | select(.name == $d.active_port)][0].availability // "") != "not available") | [.name, .description, .active_port] | @tsv')

header "<span size='small' alpha='65%'>INPUT</span>"
while IFS=$'\t' read -r name desc port; do
    IFS='|' read -r t s i <<<"$(pretty "$name $port" "$desc" mic)"
    item source "$name" "$t" "$s" "$i"
done < <(pactl -f json list sources | jq -r '.[] | select(.name|endswith(".monitor")|not) | . as $d | (.ports // []) as $p | select(([$p[] | select(.name == $d.active_port)][0].availability // "") != "not available") | [.name, .description, .active_port] | @tsv')

rows+=("Sound settings"$'\n'"<span size='small' alpha='65%'>Open Caelestia settings</span>")
metas+=($'icon\x1f'"$(~/.local/bin/rofi-icon tune on-surface-variant)")
names+=(""); kinds+=(settings); n=$((n+1))
rows+=("Advanced audio settings"$'\n'"<span size='small' alpha='65%'>Device profiles, ports and levels (pwvucontrol)</span>")
metas+=($'icon\x1f'"$(~/.local/bin/rofi-icon graphic_eq on-surface-variant)")
names+=(""); kinds+=(advanced); n=$((n+1))

i=$(for k in "${!rows[@]}"; do printf '%s\0%s|' "${rows[$k]}" "${metas[$k]}"; done | rofi -dmenu -i -eh 2 -sep '|' -markup-rows -show-icons \
    -format i -a "$(IFS=,; echo "${active[*]}")" -selected-row "$sel" -l "$n" -mesg "Sound" \
    -theme ~/.config/rofi/caelestia-menu.rasi) || exit 0

case ${kinds[$i]} in
    settings) exec caelestia shell nexus open ;;
    advanced) exec pwvucontrol ;;
    sink)
        pactl set-default-sink "${names[$i]}"
        # pindahkan suara yang sedang diputar ke output baru, seperti di Windows
        pactl -f json list sink-inputs | jq -r '.[].index' | xargs -r -I{} pactl move-sink-input {} "${names[$i]}"
        caelestia shell toaster info "Audio output" "${rows[$i]%%$'\n'*}" volume_up ;;
    source)
        pactl set-default-source "${names[$i]}"
        pactl -f json list source-outputs | jq -r '.[].index' | xargs -r -I{} pactl move-source-output {} "${names[$i]}"
        caelestia shell toaster info "Audio input" "${rows[$i]%%$'\n'*}" mic ;;
esac
