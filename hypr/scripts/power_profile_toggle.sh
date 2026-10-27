#!/bin/sh
# Power Profile Switcher untuk Laptop
# Cycler: Performance -> Balanced -> Power Saver -> Performance

current=$(powerprofilesctl get)

case "$current" in
    "performance")
        powerprofilesctl set balanced
        notify-send "Power Profile" "Switched to Balanced" -i battery-good
        ;;
    "balanced")
        powerprofilesctl set power-saver
        notify-send "Power Profile" "Switched to Power Saver" -i battery-caution
        ;;
    "power-saver")
        powerprofilesctl set performance
        notify-send "Power Profile" "Switched to Performance" -i battery-full-charging
        ;;
    *)
        powerprofilesctl set balanced
        notify-send "Power Profile" "Switched to Balanced" -i battery-good
        ;;
esac
