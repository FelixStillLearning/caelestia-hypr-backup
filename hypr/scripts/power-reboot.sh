#!/bin/bash
# Graceful reboot using hyprshutdown
hyprshutdown -p "systemctl reboot"
systemctl reboot
