#!/bin/bash
# /* ---- 💫 Audio Debug Script 💫 ---- */
# Troubleshoot audio input issues with microphone and Discord

echo "=== Audio System Debug ==="
echo ""
echo "1. PipeWire Status:"
systemctl --user status pipewire --no-pager | head -5
echo ""

echo "2. Audio Sources (Input Devices):"
pactl list sources | grep -E "^Source|Name:|Description:|Mute:" | head -20
echo ""

echo "3. Default Input Source:"
pactl get-default-source
echo ""

echo "4. Microphone Mute Status:"
if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
    echo "✗ MICROPHONE IS MUTED!"
else
    echo "✓ Microphone is NOT muted"
fi
echo ""

echo "5. Microphone Volume:"
echo "Volume: $(pamixer --default-source --get-volume)%"
echo ""

echo "6. Active Audio Streams:"
pw-dump | grep -A 5 "\"type\": \"PipeWire:Interface:Node\"" | grep -E "\"name\"|\"description\"" | head -10
echo ""

echo "7. Discord Process:"
if pgrep -f discord > /dev/null; then
    echo "✓ Discord is running"
    echo "  PID: $(pgrep -f discord)"
else
    echo "✗ Discord is NOT running"
fi
echo ""

echo "=== RECOMMENDATIONS ==="
echo "1. If microphone is MUTED, run: pamixer --default-source -u"
echo "2. If volume is LOW, run: pamixer --default-source -s 100"
echo "3. Try selecting microphone device in Discord Settings > Voice & Video"
echo "4. If issue persists, restart PipeWire:"
echo "   systemctl --user restart pipewire"
echo "5. Or restart Hyprland: Ctrl+Alt+Q"
