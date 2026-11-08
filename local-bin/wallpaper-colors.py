#!/usr/bin/env python3
"""Kelompokkan wallpaper menurut warna dominan dan terang-gelapnya.

  wallpaper-colors.py DIR    cetak baris "kategori<TAB>path relatif" untuk semua gambar

Hasil analisis disimpan di ~/.cache/wallpaper-colors.json (per path + waktu ubah),
jadi hanya gambar baru yang dianalisis ulang."""
import colorsys
import json
import os
import sys
from pathlib import Path

from PIL import Image

CACHE = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "wallpaper-colors.json"
EXT = {".jpg", ".jpeg", ".png", ".gif"}
HUES = [(20, "Merah"), (65, "Oranye & Kuning"), (170, "Hijau"), (255, "Biru"), (345, "Ungu & Pink"), (360, "Merah")]


def analyse(path):
    raw = Image.open(path).convert("RGB").resize((48, 48)).tobytes()
    rgb = [(raw[i] / 255, raw[i + 1] / 255, raw[i + 2] / 255) for i in range(0, len(raw), 3)]
    px = [colorsys.rgb_to_hsv(*c) for c in rgb]
    v = sum(0.2126 * r + 0.7152 * g + 0.0722 * b for r, g, b in rgb) / len(rgb)  # luminans
    vivid = [p for p in px if p[1] > 0.25 and p[2] > 0.2]
    tags = ["Gelap" if v < 0.3 else "Terang" if v > 0.6 else "Sedang"]
    if len(vivid) < len(px) * 0.15:
        tags.append("Monokrom")
    else:
        buckets: dict[str, float] = {}
        for h, s, _ in vivid:
            name = next(n for limit, n in HUES if h * 360 < limit)
            buckets[name] = buckets.get(name, 0) + s
        tags.append(max(buckets, key=lambda k: buckets[k]))
    return tags


def main(root):
    root = Path(root)
    try:
        cache = json.loads(CACHE.read_text())
    except (OSError, ValueError):
        cache = {}
    fresh = {}
    for f in sorted(root.rglob("*")):
        if f.suffix.lower() not in EXT or not f.is_file():
            continue
        rel, mtime = str(f.relative_to(root)), f.stat().st_mtime
        hit = cache.get(rel)
        if hit and hit["mtime"] == mtime:
            tags = hit["tags"]
        else:
            try:
                tags = analyse(f)
            except OSError:
                continue
        fresh[rel] = {"mtime": mtime, "tags": tags}
        for t in tags:
            print(f"{t}\t{rel}")
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    CACHE.write_text(json.dumps(fresh))


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--test":
        import tempfile
        with tempfile.TemporaryDirectory() as d:
            Image.new("RGB", (64, 64), (20, 40, 200)).save(f"{d}/blue.png")
            Image.new("RGB", (64, 64), (240, 240, 240)).save(f"{d}/white.png")
            assert analyse(f"{d}/blue.png") == ["Gelap", "Biru"], analyse(f"{d}/blue.png")
            assert analyse(f"{d}/white.png") == ["Terang", "Monokrom"], analyse(f"{d}/white.png")
        print("ok")
    elif len(sys.argv) == 2:
        main(sys.argv[1])
    else:
        sys.exit(__doc__)
