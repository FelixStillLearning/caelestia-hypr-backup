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
done

# VS Code: warna ikut Caelestia
vsix=$(ls "$HOME"/.local/state/caelestia/dots/vscode/caelestia-vscode-integration/*.vsix 2>/dev/null | head -1 || true)
[[ -n $vsix ]] && command -v code >/dev/null && code --install-extension "$vsix" >/dev/null 2>&1 || true

# Spotify: tema Caelestia lewat Spicetify
command -v spicetify >/dev/null && { spicetify backup apply >/dev/null 2>&1 || spicetify apply >/dev/null 2>&1 || true; }

if [[ ${1:-} == --system ]]; then
    echo "==> File sistem (butuh sudo)"
    sudo install -m755 system/usr/local/bin/* /usr/local/bin/
    sudo install -Dm644 -t /usr/local/share/caelestia-grub-theme system/usr/local/share/caelestia-grub-theme/*.pf2
    sudo install -Dm644 -t /etc/pacman.d/hooks system/etc/pacman.d/hooks/*.hook
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
