#!/usr/bin/env python3
# Tombol khusus Lenovo yang tidak dikenali driver (muncul sebagai KEY_UNKNOWN), dipetakan
# lewat scancode. Hanya membaca perangkat "Ideapad extra buttons", bukan keyboard biasa.
# Dijalankan otomatis dari ~/.config/caelestia/hypr-user.lua.
import os, re, struct, subprocess

ACTIONS = {0x148: [os.path.expanduser("~/.local/bin/audio-menu.sh")]}  # F11

blocks = open("/proc/bus/input/devices").read().split("\n\n")
dev = next("/dev/input/" + re.search(r"(event\d+)", b).group(1)
           for b in blocks if 'Name="Ideapad extra buttons"' in b)
fmt = "llHHi"; size = struct.calcsize(fmt); scan = None
with open(dev, "rb") as f:
    while data := f.read(size):
        _, _, typ, code, value = struct.unpack(fmt, data)
        if typ == 4 and code == 4:          # EV_MSC / MSC_SCAN
            scan = value
        elif typ == 1 and value == 1 and scan in ACTIONS:   # EV_KEY ditekan
            subprocess.Popen(ACTIONS[scan], start_new_session=True)
