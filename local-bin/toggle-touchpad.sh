#!/bin/bash
# Script Toggle Touchpad untuk Hyprland (Modern Lua API)

TOUCHPAD_NAME="gxtp5100:00-27c6:01e0-touchpad"
STATE_FILE="/tmp/touchpad_disabled"

if [ -f "$STATE_FILE" ]; then
    # Touchpad sedang mati -> Aktifkan
    hyprctl eval "hl.device({ name = '${TOUCHPAD_NAME}', enabled = true })"
    rm -f "$STATE_FILE"
    notify-send -u low -i input-touchpad-symbolic "Touchpad Enabled" "Touchpad diaktifkan kembali"
else
    # Touchpad sedang aktif -> Matikan
    hyprctl eval "hl.device({ name = '${TOUCHPAD_NAME}', enabled = false })"
    touch "$STATE_FILE"
    notify-send -u low -i input-touchpad-symbolic "Touchpad Disabled" "Touchpad dimatikan (Focus Mode)"
fi
