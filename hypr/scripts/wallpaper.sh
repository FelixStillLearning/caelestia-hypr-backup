#!/bin/bash

# Script to switch wallpapers and update themes using matugen, respecting existing conventions.

# --- CONFIGURATION ---
# Directory containing your wallpapers
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
# Symlink that tracks the current wallpaper, used by other scripts (rofi, hyprlock)
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper"

# --- SCRIPT LOGIC ---
# Ensure the wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
  exit 1
fi

# Get a sorted list of absolute paths for all image files.
# Using -print0 and pipe to `sort -z` and then `readarray` is the safest way to handle all special characters.
readarray -d '' wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) -print0 | sort -z)
wallpapers_count=${#wallpapers[@]}

# If no wallpapers are found, exit.
if [ "$wallpapers_count" -eq 0 ]; then
    exit 1
fi

# Reliably get the real, absolute path of the current wallpaper from the symlink.
current_wallpaper_path=$(readlink -f "$SYMLINK_PATH")

# Find the index of the current wallpaper in our list.
current_index=-1
for i in "${!wallpapers[@]}"; do
    if [[ "${wallpapers[$i]}" == "$current_wallpaper_path" ]]; then
        current_index=$i
        break
    fi
done

# If the current wallpaper isn't found in the list (e.g., it was deleted), default to the first one.
if [ "$current_index" -eq -1 ]; then
    current_index=0
fi

# Determine the next index, ensuring it wraps around correctly.
if [[ "$1" == "next" ]]; then
    next_index=$(( (current_index + 1) % wallpapers_count ))
elif [[ "$1" == "prev" ]]; then
    next_index=$(( (current_index - 1 + wallpapers_count) % wallpapers_count ))
else
    # If no or invalid argument, just pick a random one.
    next_index=$(( RANDOM % wallpapers_count ))
fi

new_wallpaper_path="${wallpapers[$next_index]}"

# 1. Change the wallpaper and generate new color scheme using caelestia.
caelestia wallpaper -f "$new_wallpaper_path"
/home/felixdev/.local/bin/sync-caelestia-rofi.py

# 2. Update the symlink to the new wallpaper, maintaining consistency with other scripts.
#    Make sure the directory for the symlink exists.
mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$new_wallpaper_path" "$SYMLINK_PATH"

# 3. Synchronize the new wallpaper with the SDDM login screen.
/home/felixdev/.local/bin/update-sddm-wallpaper.sh "$new_wallpaper_path"