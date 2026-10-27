#!/bin/sh
# Toggle Night Mode (wlsunset)

if pgrep -x wlsunset > /dev/null; then
    pkill wlsunset
    notify-send "Night Mode" "Disabled (Manual Override)" -i display-brightness-symbolic
else
    # Koordinat Jakarta (Default)
    wlsunset -l -6.2088 -L 106.8456 -t 3500 -T 6500 &
    notify-send "Night Mode" "Enabled (Auto)" -i weather-clear-night
fi
