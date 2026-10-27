<div align="center">

# caelestia-hypr-backup

**Snapshot konfigurasi Hyprland + Caelestia Shell milik felixdev**

Disimpan sebelum migrasi ke [caelestia-kde](https://github.com/ladybug-me/caelestia-kde), supaya setup lama bisa dipulihkan kapan saja.

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=archlinux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-Lua_config-58E1FF?style=for-the-badge&logo=hyprland&logoColor=black)
![Caelestia](https://img.shields.io/badge/Caelestia-Quickshell-B4A4F4?style=for-the-badge)
![Wayland](https://img.shields.io/badge/Wayland-FFBC00?style=for-the-badge&logo=wayland&logoColor=black)

</div>

---

## Daftar Isi

- [Sekilas](#sekilas)
- [Spesifikasi Sistem](#spesifikasi-sistem)
- [Struktur Repo](#struktur-repo)
- [Cara Kerja Config](#cara-kerja-config)
- [Aplikasi Default](#aplikasi-default)
- [Tampilan](#tampilan)
- [Keybind](#keybind)
- [Autostart](#autostart)
- [Dependensi](#dependensi)
- [Cara Memulihkan](#cara-memulihkan)
- [Catatan](#catatan)
- [Kredit](#kredit)

---

## Sekilas

Repo ini berisi dua folder yang disalin apa adanya dari `~/.config`:

| Folder | Asal | Isi |
|---|---|---|
| `hypr/` | `~/.config/hypr` | Config Hyprland (format Lua), skema warna, script utilitas |
| `caelestia/` | `~/.config/caelestia` | Setelan Caelestia Shell dan override variabel Hyprland |

Setup ini mengikuti struktur dotfiles resmi [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia), dengan penyesuaian pribadi pada aplikasi default, keybind, touchpad, dan tampilan.

## Spesifikasi Sistem

| Komponen | Detail |
|---|---|
| OS | Arch Linux (kernel 7.2) |
| Compositor | Hyprland, config berbasis Lua |
| Shell desktop | Caelestia Shell (Quickshell) |
| CPU / GPU | AMD Ryzen AI 7 350, Radeon 860M |
| Layar | `eDP-1` 1920x1200 @ 60 Hz |
| Shell terminal | fish |

## Struktur Repo

```text
.
├── caelestia/
│   ├── shell.json            # setelan Caelestia Shell (transparansi, satuan, bahasa)
│   ├── monitors/eDP-1/       # setelan shell per monitor
│   ├── hypr-vars.lua         # override variabel Hyprland (misal jumlah jari swipe)
│   ├── hypr-user.lua         # tempat config Hyprland tambahan milik user
│   └── user-config.fish      # tambahan config fish
└── hypr/
    ├── hyprland.lua          # entrypoint utama: memuat semua modul di bawah
    ├── variables.lua         # SATU tempat untuk aplikasi, gaps, blur, dan semua keybind
    ├── hyprland/             # modul: env, general, input, misc, animations,
    │                         #        decoration, group, execs, rules, gestures, keybinds
    ├── scheme/               # skema warna (current.lua dibuat otomatis dari wallpaper)
    ├── utils/                # helper Lua (functions.lua, json.lua)
    ├── hypridle.conf         # aturan idle
    ├── hyprlock.conf         # tampilan layar kunci
    ├── scripts/              # script shell utilitas (wallpaper picker, power, dll.)
    │
    │   -- arsip config sebelum Caelestia --
    ├── hyprland.conf         # config lama format .conf (kitty, rofi, Waybar)
    ├── configs/              # potongan config lama: keybinds, windowrules, animasi, dll.
    └── colors.conf           # warna untuk config lama
```

## Cara Kerja Config

`hyprland.lua` adalah titik masuknya. Urutan yang dijalankan:

1. Jika `scheme/current.lua` belum ada, salin dari `scheme/default.lua`.
2. Buat `~/.config/caelestia/hypr-vars.lua` jika belum ada, lalu timpa nilai di `variables.lua` dengan isinya.
3. Pasang monitor default (`preferred`, posisi `auto`, scale `1`).
4. Muat modul di `hyprland/` satu per satu.
5. Terakhir, muat `~/.config/caelestia/hypr-user.lua` untuk tambahan pribadi.

Hampir semua penyesuaian cukup dilakukan di **`hypr/variables.lua`**. Untuk perubahan yang ingin bertahan saat dotfiles Caelestia di-update, taruh di **`caelestia/hypr-vars.lua`** atau **`caelestia/hypr-user.lua`**.

## Aplikasi Default

| Peran | Aplikasi |
|---|---|
| Terminal | `foot` |
| Browser | `zen-browser` |
| Editor | `codium` |
| File manager | `thunar` |
| Pengaturan audio | `pavucontrol` |
| Cursor | `sweet-cursors`, ukuran 24 |

## Tampilan

| Pengaturan | Nilai |
|---|---|
| Opasitas jendela | 0.95 |
| Sudut jendela | 15 px |
| Border | 1 px, warna mengikuti skema wallpaper |
| Gaps | dalam 5, luar 10, satu jendela 20 |
| Blur | aktif, ukuran 8, 2 pass, termasuk popup |
| Shadow | aktif, range 15 |
| Transparansi shell | aktif |

Warna seluruh desktop dihasilkan otomatis dari wallpaper oleh Caelestia (Material You).

## Keybind

`SUPER` adalah tombol Windows.

### Aplikasi dan Shell

| Shortcut | Aksi |
|---|---|
| `SUPER` (tekan lalu lepas) | Launcher Caelestia |
| `SUPER + Enter` | Terminal |
| `SUPER + SHIFT + Enter` | Terminal mengambang |
| `SUPER + B` | Browser |
| `SUPER + C` | Editor |
| `SUPER + E` | File manager |
| `SUPER + W` | Pilih wallpaper |
| `SUPER + N` | Sidebar notifikasi |
| `SUPER + K` | Tampilkan semua panel |
| `CTRL + ALT + Delete` | Menu sesi (logout, restart, shutdown) |
| `CTRL + ALT + V` | Pengaturan audio |

### Jendela

| Shortcut | Aksi |
|---|---|
| `SUPER + Q` | Tutup jendela |
| `SUPER + F` | Fullscreen |
| `SUPER + ALT + F` | Maximize (tetap ada border) |
| `SUPER + ALT + Space` | Floating on/off |
| `SUPER + P` | Pin jendela |
| `SUPER + ALT + \` | Mode picture-in-picture |
| `CTRL + SUPER + \` | Taruh jendela di tengah |
| `SUPER + Panah` | Pindah fokus |
| `SUPER + SHIFT + Panah` | Pindahkan jendela |
| `SUPER + -` / `SUPER + =` | Ubah lebar |
| `SUPER + SHIFT + -` / `SUPER + SHIFT + =` | Ubah tinggi |
| `SUPER + Klik kiri` / `SUPER + Z` | Geser jendela |
| `SUPER + Klik kanan` / `SUPER + X` | Ubah ukuran jendela |
| `ALT + Tab` | Ganti jendela |

### Workspace

| Shortcut | Aksi |
|---|---|
| `SUPER + 1..0` | Ke workspace 1 sampai 10 |
| `SUPER + ALT + 1..0` | Pindahkan jendela ke workspace |
| `SUPER + Scroll` / `SUPER + Page Up/Down` | Workspace sebelumnya / berikutnya |
| `SUPER + S` | Special workspace |
| `SUPER + ALT + S` | Kirim jendela ke special workspace |
| `SUPER + M` | Workspace musik |
| `SUPER + R` | Workspace todo |
| `CTRL + SHIFT + Escape` | Workspace system monitor |
| Swipe 3 jari | Ganti workspace |

### Utilitas

| Shortcut | Aksi |
|---|---|
| `Print` | Screenshot penuh |
| `SUPER + SHIFT + S` | Screenshot area (layar dibekukan) |
| `SUPER + SHIFT + ALT + S` | Screenshot area |
| `CTRL + ALT + R` | Rekam layar |
| `SUPER + ALT + R` | Rekam layar dengan suara |
| `SUPER + SHIFT + ALT + R` | Rekam area |
| `SUPER + SHIFT + C` | Color picker |
| `SUPER + V` | Riwayat clipboard |
| `SUPER + ALT + V` | Hapus item clipboard |
| `SUPER + .` | Pemilih emoji |
| `SUPER + L` | Kunci layar |
| `SUPER + SHIFT + L` | Sleep (suspend lalu hibernate) |
| `SUPER + ALT + T` | Touchpad on/off |

### Media

| Shortcut | Aksi |
|---|---|
| `CTRL + SUPER + Space` | Play / pause |
| `CTRL + SUPER + =` / `-` | Lagu berikutnya / sebelumnya |
| `SUPER + SHIFT + M` | Mute |
| Tombol media dan kecerahan laptop | Berfungsi, termasuk saat layar terkunci |

### Darurat

| Shortcut | Aksi |
|---|---|
| `CTRL + SUPER + ALT + R` | Restart Caelestia Shell |
| `CTRL + SUPER + SHIFT + R` | Matikan Caelestia Shell |
| `SUPER + ALT + L` | Pulihkan layar kunci jika shell crash |

Daftar lengkap ada di `hypr/variables.lua` bagian `KEYBINDS`.

## Autostart

Dijalankan sekali saat Hyprland menyala (`hypr/hyprland/execs.lua`):

- `gnome-keyring-daemon` dan `polkit-gnome`: penyimpanan password dan dialog izin
- `cliphist`: riwayat clipboard teks dan gambar
- `trash-empty 30`: kosongkan isi tong sampah yang lebih dari 30 hari
- Cursor theme untuk Hyprland dan aplikasi GTK
- `geoclue` + `gammastep`: night light berdasarkan lokasi
- `mpris-proxy`: tombol media headset Bluetooth
- `caelestia shell -d`: menyalakan shell

Selain itu, jendela Bitwarden dan picture-in-picture otomatis dibuat mengambang dengan ukuran yang pas.

## Dependensi

Paket inti:

```bash
yay -S hyprland caelestia-shell caelestia-cli quickshell-git
```

Paket yang dipakai oleh config ini:

```bash
yay -S foot zen-browser-bin vscodium-bin thunar pavucontrol \
       wl-clipboard cliphist fuzzel ydotool hyprpicker \
       trash-cli gammastep geoclue bluez-utils \
       gnome-keyring polkit-gnome wireplumber sweet-cursors-theme-git
```

Nama paket AUR bisa berubah. Cek dulu dengan `yay -Ss <nama>` jika ada yang tidak ditemukan.

## Cara Memulihkan

Backup dulu config yang sedang dipakai, lalu salin isi repo ini:

```bash
git clone https://github.com/FelixStillLearning/caelestia-hypr-backup.git
cd caelestia-hypr-backup

# simpan config yang sekarang
mv ~/.config/hypr      ~/.config/hypr.bak-$(date +%F)
mv ~/.config/caelestia ~/.config/caelestia.bak-$(date +%F)

# pulihkan
cp -a hypr      ~/.config/hypr
cp -a caelestia ~/.config/caelestia
```

Setelah itu logout dan pilih sesi **Hyprland** di layar login. Kalau shell tidak muncul, jalankan:

```bash
caelestia shell -d
```

## Catatan

- `hypr/current_wallpaper` adalah symlink ke `~/Pictures/wallpapers/...`. Kalau file wallpaper itu tidak ada, pilih ulang wallpaper lewat `SUPER + W` atau `caelestia wallpaper -f <gambar>`.
- `hypr/scheme/current.*` dibuat ulang otomatis setiap ganti wallpaper, jadi tidak perlu diedit manual.
- Keybind touchpad memanggil `~/.local/bin/toggle-touchpad.sh`. File itu ada di luar repo ini.
- `hypr/hyprland.conf`, `hypr/configs/`, dan sebagian `hypr/scripts/` (Waybar, wlogout, rofi) adalah config lama sebelum pindah ke Caelestia. Disimpan sebagai arsip dan tidak dimuat oleh `hyprland.lua`.

## Kredit

- [caelestia-dots](https://github.com/caelestia-dots) oleh [soramanew](https://github.com/soramanew): shell dan struktur dotfiles yang menjadi dasar setup ini
- [Hyprland](https://hyprland.org)
- [Quickshell](https://quickshell.org)
