#!/usr/bin/env bash
# Pasang config ini di atas Caelestia dots yang sudah terinstall.
#   ./install.sh            config user (~/.config, ~/.local/bin)
#   ./install.sh --system   + file sistem (sudoers, hook pacman, tema GRUB/login); minta password sudo
# Config lama selalu dibackup dulu ke ~/.config-backup-<tanggal>.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

backup="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
ask() { read -rp "$1 [y/N] " a; [[ $a == [yYlL]* ]]; }

save() {  # simpan salinan file/folder lama sebelum ditimpa
    [[ -e $1 || -L $1 ]] || return 0
    mkdir -p "$backup/$(dirname "${1#"$HOME"/}")"
    cp -a "$1" "$backup/${1#"$HOME"/}"
}

echo "==> Config user"
for d in hypr caelestia rofi; do
    save "$HOME/.config/$d"
    mkdir -p "$HOME/.config/$d"
    cp -a "$d/." "$HOME/.config/$d/"
done
# Font seragam: SF Pro (teks) dan JetBrains Mono (monospace)
mkdir -p "$HOME/.config/fontconfig/conf.d"
cp fontconfig/50-default-fonts.conf "$HOME/.config/fontconfig/conf.d/"
fc-cache -f >/dev/null 2>&1 || true
if command -v gsettings >/dev/null; then
    gsettings set org.gnome.desktop.interface font-name 'SF Pro Text 10'
    gsettings set org.gnome.desktop.interface document-font-name 'SF Pro Text 10'
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 10'
fi

mkdir -p "$HOME/.local/bin"
for f in local-bin/*; do
    save "$HOME/.local/bin/${f##*/}"
    install -m755 "$f" "$HOME/.local/bin/"
done

# Zen Browser: pakai warna Caelestia lewat userChrome.css
for p in "$HOME"/.zen/*/prefs.js; do
    [[ -f $p ]] || continue
    prof=${p%/prefs.js}
    mkdir -p "$prof/chrome"
    ln -sfn "$HOME/.local/state/caelestia/theme/zen-userChrome.css" "$prof/chrome/userChrome.css"
    grep -qs legacyUserProfileCustomizations "$prof/user.js" ||
        echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$prof/user.js"
    # startpage Caelestia untuk homepage dan Ctrl+T (tab baru butuh ./install.sh --system)
    grep -qs startpage.html "$prof/user.js" || {
        echo 'user_pref("zen.urlbar.replace-newtab", false);'
        echo "user_pref(\"browser.startup.homepage\", \"file://$HOME/.local/state/caelestia/theme/startpage.html\");"
    } >> "$prof/user.js"
done

# Obsidian: snippet warna Caelestia di setiap vault
vaults=$(jq -r '.vaults[].path' "$HOME/.config/obsidian/obsidian.json" 2>/dev/null || true)
while IFS= read -r v; do
    [[ -n $v && -d $v/.obsidian ]] || continue
    mkdir -p "$v/.obsidian/snippets"
    ln -sfn "$HOME/.local/state/caelestia/theme/obsidian-caelestia.css" "$v/.obsidian/snippets/caelestia.css"
    a="$v/.obsidian/appearance.json"; [[ -f $a ]] || echo '{}' > "$a"
    jq '.enabledCssSnippets = ((.enabledCssSnippets // []) - ["caelestia"] + ["caelestia"])' "$a" > "$a.tmp" && mv "$a.tmp" "$a"
    # vault yang disinkron git: snippet berubah tiap ganti wallpaper, jangan ikut di-commit
    if [[ -d $v/.git ]]; then
        grep -qsx '.obsidian/snippets/caelestia.css' "$v/.gitignore" || echo '.obsidian/snippets/caelestia.css' >> "$v/.gitignore"
    fi
done <<< "$vaults"

# VS Code: warna ikut Caelestia
vsix=$(ls "$HOME"/.local/state/caelestia/dots/vscode/caelestia-vscode-integration/*.vsix 2>/dev/null | head -1 || true)
[[ -n $vsix ]] && command -v code >/dev/null && code --install-extension "$vsix" >/dev/null 2>&1 || true

# Jarvis: suara offline (Piper TTS + model suara jarvis-high, sekitar 300 MB)
if command -v ffmpeg >/dev/null && ask "Pasang suara Jarvis (sambutan login, briefing SUPER+J, peringatan baterai)?"; then
    piper="$HOME/.local/share/piper"
    [[ -x $piper/venv/bin/piper ]] || { python -m venv "$piper/venv" && "$piper/venv/bin/pip" install -q piper-tts; }
    mkdir -p "$piper/voices"
    j=https://huggingface.co/jgkawell/jarvis/resolve/main/en/en_GB/jarvis/high/jarvis-high.onnx
    for f in "$j" "$j.json"; do
        [[ -s $piper/voices/${f##*/} ]] || curl -fL --progress-bar -o "$piper/voices/${f##*/}" "$f"
    done
    # "Hey Jarvis" + perintah suara: openWakeWord (tanpa tflite) dan Whisper
    "$piper/venv/bin/pip" install -q faster-whisper scipy tqdm requests scikit-learn
    "$piper/venv/bin/pip" install -q --no-deps openwakeword
    "$piper/venv/bin/python" -c 'import openwakeword.utils as u; u.download_models(model_names=["hey_jarvis"])' >/dev/null 2>&1
    mkdir -p "$HOME/.config/jarvis" "$HOME/.config/quickshell/jarvis-island"
    [[ -f $HOME/.config/jarvis/config.json ]] || install -m600 jarvis/config.example.json "$HOME/.config/jarvis/config.json"
    cp quickshell/jarvis-island/shell.qml "$HOME/.config/quickshell/jarvis-island/"
fi

# Spotify: tema Caelestia lewat Spicetify
command -v spicetify >/dev/null && { spicetify backup apply >/dev/null 2>&1 || spicetify apply >/dev/null 2>&1 || true; }

if [[ ${1:-} == --system ]]; then
    echo "==> File sistem (butuh sudo)"
    sudo install -m755 system/usr/local/bin/* /usr/local/bin/
    sudo install -Dm644 -t /usr/local/share/caelestia-grub-theme system/usr/local/share/caelestia-grub-theme/*.pf2
    sudo install -Dm644 -t /etc/pacman.d/hooks system/etc/pacman.d/hooks/*.hook
    if [[ -d /opt/zen-browser-bin ]]; then  # tab baru Zen = startpage Caelestia
        sudo install -Dm644 system/opt/zen-browser-bin/defaults/pref/autoconfig.js /opt/zen-browser-bin/defaults/pref/autoconfig.js
        sudo install -m644 system/opt/zen-browser-bin/mozilla.cfg /opt/zen-browser-bin/mozilla.cfg
    fi
    if command -v kdeconnectd >/dev/null && command -v ufw >/dev/null; then  # port KDE Connect
        sudo ufw allow 1714:1764/udp >/dev/null
        sudo ufw allow 1714:1764/tcp >/dev/null
    fi
    for f in system/etc/sudoers.d/*; do
        tmp=$(mktemp)
        sed "s/%USER%/$USER/" "$f" > "$tmp"
        sudo visudo -cqf "$tmp" && sudo install -m440 "$tmp" "/etc/sudoers.d/${f##*/}"
        rm -f "$tmp"
    done
    if ask "Pasang perbaikan mic AMD (hanya untuk Lenovo IdeaPad Slim 5 AMD yang mic internalnya mati)?"; then
        sudo install -m644 system/etc/modprobe.d/blacklist-amd-dmic.conf /etc/modprobe.d/
        echo "   Restart supaya perbaikan mic aktif."
    fi
    [[ -d /usr/share/sddm/themes/caelestia ]] && sudo /usr/local/bin/caelestia-sddm-greeting || true
    [[ -d /boot/grub ]] && sudo /usr/local/bin/caelestia-grub-theme || true
fi

echo
echo "Selesai. Config lama dibackup di: $backup"
echo "Logout lalu login lagi (atau restart Hyprland) supaya semua perubahan dimuat."
[[ ${1:-} == --system ]] || echo "Untuk tema login/GRUB, sudoers, dan hook pacman: jalankan ./install.sh --system"
