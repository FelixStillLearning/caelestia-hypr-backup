#!/usr/bin/env bash
# Menu mode pengisian baterai (SUPER+ALT+B). Izin tanpa password dari /etc/sudoers.d/battery-charge-mode
f=/sys/class/power_supply/BAT0/charge_types
modes=(Fast Standard Long_Life)
titles=("Fast" "Standard" "Long Life")
descs=("Quick charge to 100%" "Normal charge to 100%" "Stop at around 80% to extend battery lifespan")
icons=(bolt battery_charging_full eco)   # Material Symbols
cur=$(grep -o '\[[^]]*\]' "$f" | tr -d '[]')

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
    -a "$active" -selected-row "$active" -mesg "Battery Charge Mode" \
    -theme ~/.config/rofi/caelestia-menu.rasi) || exit 0

if echo "${modes[$i]}" | sudo -n tee "$f" >/dev/null 2>&1; then
    notify-send -a "Battery" "Battery mode: ${titles[$i]}"
else
    notify-send -u critical -a "Battery" "Failed to change battery mode" "Permission not installed (/etc/sudoers.d/battery-charge-mode)."
fi
