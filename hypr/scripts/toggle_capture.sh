#!/bin/bash
# Script to toggle the actual hardware capture switch (numid=9) and send a notification.

# Icon directory from your original script
iDIR="$HOME/.config/swaync/icons"

# Toggle the capture switch for card 1, numid 9
amixer -c 1 cset numid=9 toggle > /dev/null

# Check the new state of the capture switch
# We grep for the specific "values=on,on" line.
if amixer -c 1 cget numid=9 | grep -q ': values=on,on'; then
  # If it's on, show the 'unmuted' notification
  notify-send -e -u low -i "$iDIR/microphone.png" "Microphone:" "Switched ON"
  swayosd-client --input-volume 50 # Example: show 50% on OSD, since it's just a toggle
else
  # If it's off, show the 'muted' notification
  notify-send -e -u low -i "$iDIR/microphone-mute.png" "Microphone:" "Switched OFF"
  swayosd-client --input-volume 0 # Show 0% on OSD for mute
fi

# Signal Waybar to update its pulseaudio module
pkill -SIGRTMIN+8 waybar