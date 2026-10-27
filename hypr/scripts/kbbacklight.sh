#!/bin/bash
# Nama device kamu
DEVICE="platform::kbd_backlight"

# Ambil nilai kecerahan sekarang & maksimal
CURRENT=$(brightnessctl -d $DEVICE g)
MAX=$(brightnessctl -d $DEVICE m)

# Logika: Kalau belum mentok, tambah 1. Kalau udah mentok, matikan.
if [ "$CURRENT" -lt "$MAX" ]; then
    brightnessctl -d $DEVICE s +1
else
    brightnessctl -d $DEVICE s 0
fi
