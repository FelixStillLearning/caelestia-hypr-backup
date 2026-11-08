#!/usr/bin/env bash
# Mode pesawat (F8). Firmware Lenovo sudah mematikan/menyalakan WiFi sendiri saat F8 ditekan;
# script ini hanya menyamakan Bluetooth dengan status WiFi lalu menampilkan toast.
sleep 0.5   # tunggu firmware selesai mengubah status WiFi
if rfkill -rn -o TYPE,SOFT | grep -q '^wlan blocked'; then
    rfkill block bluetooth
    caelestia shell toaster info "Airplane mode on" "Wi-Fi and Bluetooth are off" airplanemode_active
else
    rfkill unblock bluetooth
    caelestia shell toaster info "Airplane mode off" "Wi-Fi and Bluetooth are on" airplanemode_inactive
fi
