#!/bin/sh
# Tombol kuning hyprbars: pindahkan jendela aktif ke special workspace,
# atau kembalikan ke workspace biasa kalau jendela sudah ada di sana.
case "$(hyprctl -j activewindow | jq -r '.workspace.name')" in
    special:*) ws="e+0" ;;
    *) ws="special:special" ;;
esac
hyprctl dispatch "hl.dsp.window.move({ workspace = \"$ws\" })"
