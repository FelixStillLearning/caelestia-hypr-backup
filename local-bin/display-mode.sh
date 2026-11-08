#!/usr/bin/env bash
# Menu mode layar (SUPER+P / F7). Logika ada di ~/.config/caelestia/hypr-user.lua
modes=(laptop mirror extend external)
titles=("PC screen only" "Duplicate" "Extend" "Second screen only")
descs=("Turn off external display" "Show the same image on both screens" "Use external display as a second screen" "Turn off laptop screen")
icons=(laptop screen_share splitscreen_right tv)   # Material Symbols
cur=$(cat ~/.local/state/display-mode 2>/dev/null || echo extend)

~/.local/bin/sync-caelestia-rofi.py   # warna ikut skema Caelestia terbaru
active=0
for i in "${!modes[@]}"; do [[ ${modes[$i]} == "$cur" ]] && active=$i; done

entries() {
    for i in "${!modes[@]}"; do
        color=on-surface-variant; [[ $i == "$active" ]] && color=primary
        printf '%s\n%s\0icon\x1f%s|' "${titles[$i]}" "<span size='small' alpha='65%'>${descs[$i]}</span>" \
            "$(~/.local/bin/rofi-icon "${icons[$i]}" "$color")"
    done
}

i=$(entries | rofi -dmenu -i -eh 2 -sep '|' -markup-rows -show-icons -format i \
    -a "$active" -selected-row "$active" -mesg "Display Mode" \
    -theme ~/.config/rofi/caelestia-menu.rasi) || exit 0

hyprctl eval "DisplayMode('${modes[$i]}')" >/dev/null
notify-send -a "Display Mode" "Display mode: ${titles[$i]}"
