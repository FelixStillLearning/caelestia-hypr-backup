#!/bin/bash

# === CONFIG ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper"
ICONS="$HOME/.cache/rofi-icons"

cd "$WALLPAPER_DIR" || exit 1

# === handle spaces in names ===
IFS=$'\n'

# === SYNC ROFI COLORS WITH CAELESTIA ===
"$HOME"/.local/bin/sync-caelestia-rofi.py

# === KATEGORI: warna dominan (dianalisis + cache) dan subfolder ===
mapfile -t TAGGED < <("$HOME"/.local/bin/wallpaper-colors.py "$WALLPAPER_DIR")
declare -A COUNT
for line in "${TAGGED[@]}"; do COUNT[${line%%$'\t'*}]=$(( ${COUNT[${line%%$'\t'*}]:-0} + 1 )); done
mapfile -t ALL < <(printf '%s\n' "${TAGGED[@]}" | cut -f2 | sort -u)

swatch() {  # lingkaran warna untuk kategori warna
    mkdir -p "$ICONS"
    local out="$ICONS/swatch-${1#\#}.svg"
    [[ -f $out ]] || printf '<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48"><circle cx="24" cy="24" r="18" fill="%s"/></svg>\n' "$1" > "$out"
    echo "$out"
}

pick_category() {
    local names=() labels=() icons=()
    names+=("@all"); labels+=("Semua"); icons+=("$("$HOME"/.local/bin/rofi-icon photo_library primary)")
    local colors=("Gelap:#1e1e2e" "Terang:#e8e8ee" "Sedang:#7f8496" "Monokrom:#9a9a9a" "Biru:#4d7fe0"
                  "Ungu & Pink:#b56ad8" "Merah:#d9534f" "Oranye & Kuning:#f0a030" "Hijau:#4caf6a")
    for c in "${colors[@]}"; do
        [[ ${COUNT[${c%%:*}]:-0} -gt 0 ]] || continue
        names+=("@${c%%:*}"); labels+=("${c%%:*}"); icons+=("$(swatch "${c##*:}")")
    done
    local folder_icon d n
    folder_icon=$("$HOME"/.local/bin/rofi-icon folder on-surface-variant)
    while IFS=$'\t' read -r n d; do
        names+=("$d"); labels+=("$d"); icons+=("$folder_icon"); COUNT[$d]=$n
    done < <(printf '%s\n' "${ALL[@]}" | grep / | cut -d/ -f1 | sort | uniq -c | sort -rn | awk '{c=$1; $1=""; sub(/^ /,""); print c "\t" $0}')

    local i
    i=$(for k in "${!names[@]}"; do
            local key=${names[$k]#@}
            [[ ${names[$k]} == "@all" ]] && n=${#ALL[@]} || n=${COUNT[$key]}
            printf '%s\n%s\0icon\x1f%s|' "${labels[$k]}" "<span size='small' alpha='65%'>$n wallpapers</span>" "${icons[$k]}"
        done | rofi -dmenu -i -eh 2 -sep '|' -markup-rows -show-icons -format i \
                -mesg "Wallpaper" -theme "$HOME/.config/rofi/caelestia-menu.rasi" \
                -theme-str 'listview { lines: 8; scrollbar: false; }') || return 1
    echo "${names[$i]}"
}

files_in() {  # path relatif untuk satu kategori, terbaru dulu
    case $1 in
        @all) printf '%s\n' "${ALL[@]}" ;;
        @*)   printf '%s\n' "${TAGGED[@]}" | awk -F'\t' -v t="${1#@}" '$1 == t { print $2 }' ;;
        *)    printf '%s\n' "${ALL[@]}" | grep -F "$1/" | grep "^$1/" ;;
    esac | tr '\n' '\0' | xargs -0 stat -c '%Y|%n' | sort -t'|' -k1,1nr | cut -d'|' -f2-
}

# === PILIH KATEGORI, LALU GAMBAR (Esc di grid = kembali ke kategori) ===
while true; do
    CATEGORY=$(pick_category) || exit 1
    SELECTED_WALL=$(files_in "$CATEGORY" | while read -r relpath; do
            echo -en "${relpath}\0icon\x1f${WALLPAPER_DIR}/${relpath}\n"
        done | rofi -dmenu -theme "$HOME/.config/rofi/wallpaper-picker.rasi")
    [ -n "$SELECTED_WALL" ] && break
done
SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_WALL"

# === SET WALLPAPER & DYNAMIC SCHEME ===
caelestia wallpaper -f "$SELECTED_PATH"
"$HOME"/.local/bin/sync-caelestia-rofi.py

# === CREATE SYMLINK ===
mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"
