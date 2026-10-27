#!/bin/sh
# Toggle hypridle via systemd user service (simple idle inhibit)
if systemctl --user is-active --quiet hypridle.service; then
  systemctl --user stop hypridle.service && notify-send "Idle Inhibit" "hypridle stopped"
else
  systemctl --user start hypridle.service && notify-send "Idle Inhibit" "hypridle started"
fi
