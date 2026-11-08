#!/usr/bin/env python3
import re
import pathlib

def sync_theme():
    lua_path = pathlib.Path.home() / ".config/hypr/scheme/current.lua"
    rofi_path = pathlib.Path.home() / ".config/rofi/colors.rasi"
    
    if not lua_path.exists():
        return

    content = lua_path.read_text()
    matches = dict(re.findall(r"(\w+)\s*=\s*\"([0-9a-fA-F]{6})\"", content))

    # 1. Sync Rofi colors
    lines = ["* {"]
    for k, v in matches.items():
        clean_k = k.replace("_", "-")
        clean_k = re.sub(r"([a-z0-9])([A-Z])", r"\1-\2", clean_k).lower()
        lines.append(f"    {clean_k}: #{v};")
    lines.append("}")

    rofi_path.parent.mkdir(parents=True, exist_ok=True)
    rofi_path.write_text("\n".join(lines) + "\n")


if __name__ == "__main__":
    sync_theme()
