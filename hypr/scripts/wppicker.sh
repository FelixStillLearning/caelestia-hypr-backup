#!/bin/bash

# === CONFIG ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper"

cd "$WALLPAPER_DIR" || exit 1

# === handle spaces in names ===
IFS=$'\n'

# === SYNC ROFI COLORS WITH CAELESTIA ===
"$HOME"/.local/bin/sync-caelestia-rofi.py

# === ICON-PREVIEW SELECTION (recursive, newest first) ===
SELECTED_WALL=$(find . -type f \
		\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \) \
		-printf '%T@|%P\0' \
	| sort -z -nr \
	| while IFS='|' read -r -d '' _ts relpath; do
				# rofi entry uses relative path for display, absolute path for icon preview
				echo -en "${relpath}\0icon\x1f${WALLPAPER_DIR}/${relpath}\n"
		done \
	| rofi -dmenu -theme "$HOME/.config/rofi/wallpaper-picker.rasi")
[ -z "$SELECTED_WALL" ] && exit 1
SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_WALL"

# === SET WALLPAPER & DYNAMIC SCHEME ===
caelestia wallpaper -f "$SELECTED_PATH"
"$HOME"/.local/bin/sync-caelestia-rofi.py

# === CREATE SYMLINK ===
mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"


