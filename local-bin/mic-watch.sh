#!/usr/bin/env bash
# Toast Caelestia tiap kali mic default di-mute/unmute (oleh tombol F4 maupun aplikasi).
# Dijalankan otomatis dari ~/.config/caelestia/hypr-user.lua saat Hyprland start.
state() { wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo muted || echo on; }
last=$(state)
while true; do   # sambung ulang kalau PipeWire di-restart
pactl subscribe | grep --line-buffered -E "on (source|server)" | while read -r _; do
    now=$(state)
    [[ $now == "$last" ]] && continue
    last=$now
    if [[ $now == muted ]]; then
        caelestia shell toaster warn "Microphone muted" "Others can't hear you" mic_off
    else
        caelestia shell toaster info "Microphone on" "Others can hear you" mic
    fi
done
sleep 2
done
