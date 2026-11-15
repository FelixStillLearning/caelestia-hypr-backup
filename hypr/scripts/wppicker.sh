#!/bin/bash

# === CONFIG ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper"

cd "$WALLPAPER_DIR" || exit 1

# === handle spaces in names ===
IFS=$'\n'

# === SYNC ROFI COLORS WITH CAELESTIA ===
"$HOME"/.local/bin/sync-caelestia-rofi.py

# === AMBIL SEMUA WALLPAPER (TERBARU DULU) ===
mapfile -t FILES < <(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) -printf '%T@|%P\n' | sort -t'|' -k1,1nr | cut -d'|' -f2-)

[ ${#FILES[@]} -eq 0 ] && exit 1

# === THUMBNAIL SQUIRCLE MACOS (cache; GIF diambil frame pertama) ===
THUMBS="$HOME/.cache/rofi-wall-thumbs"; mkdir -p "$THUMBS"
thumb_of() { printf '%s/%s.png' "$THUMBS" "$(printf '%s' "$1$(stat -c %Y "$WALLPAPER_DIR/$1")" | md5sum | cut -c1-16)"; }
make_thumb() {  # $1 = path relatif
    local out; out=$(thumb_of "$1"); [[ -s $out ]] && return
    ffmpeg -v error -y -i "$WALLPAPER_DIR/$1" -frames:v 1 -vf "scale=480:480:force_original_aspect_ratio=increase,crop=480:480,format=rgba,geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='if(lte(hypot(max(0,abs(X-W/2)-(W/2-44)),max(0,abs(Y-H/2)-(H/2-44))),44),255,0)'" "$out" || rm -f "$out"
}
export -f make_thumb thumb_of; export WALLPAPER_DIR THUMBS

# Buat thumbnail paralel (hanya file baru yang belum ada di cache)
printf '%s\0' "${FILES[@]}" | xargs -0 -P8 -I{} bash -c 'make_thumb "$1"' _ {}

# === TAMPILKAN GRID WALLPAPER LANGSUNG ===
IDX=$(for relpath in "${FILES[@]}"; do
        name=$(basename "$relpath"); name=${name%.*}
        printf '%s\0icon\x1f%s\n' "$name" "$(thumb_of "$relpath")"
    done | rofi -dmenu -i -format i -theme "$HOME/.config/rofi/wallpaper-picker.rasi")

[ -z "$IDX" ] && exit 0

SELECTED_WALL=${FILES[$IDX]}
SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_WALL"

# === SET WALLPAPER & DYNAMIC SCHEME ===
caelestia wallpaper -f "$SELECTED_PATH"
"$HOME"/.local/bin/sync-caelestia-rofi.py

# === CREATE SYMLINK ===
mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"
