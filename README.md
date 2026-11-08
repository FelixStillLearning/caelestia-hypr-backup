<div align="center">

# caelestia-hypr-backup

**Konfigurasi Hyprland + Caelestia Shell milik felixdev**

Satu tema dari tombol power sampai desktop: menu GRUB, layar boot, layar login, desktop, dan aplikasi semuanya ikut warna wallpaper.

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=archlinux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-Lua_config-58E1FF?style=for-the-badge&logo=hyprland&logoColor=black)
![Caelestia](https://img.shields.io/badge/Caelestia-Quickshell-B4A4F4?style=for-the-badge)
![Wayland](https://img.shields.io/badge/Wayland-FFBC00?style=for-the-badge&logo=wayland&logoColor=black)

</div>

---

## Daftar Isi

- [Sekilas](#sekilas)
- [Cara Pasang](#cara-pasang)
- [Fitur Tambahan](#fitur-tambahan)
- [Tema Seragam](#tema-seragam)
- [Spesifikasi Sistem](#spesifikasi-sistem)
- [Struktur Repo](#struktur-repo)
- [Cara Kerja Config](#cara-kerja-config)
- [Aplikasi Default](#aplikasi-default)
- [Tampilan](#tampilan)
- [Keybind](#keybind)
- [Autostart](#autostart)
- [Khusus Perangkat Keras](#khusus-perangkat-keras)
- [Catatan](#catatan)
- [Kredit](#kredit)

---

## Sekilas

Setup ini dibangun di atas dotfiles resmi [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia). Semua penyesuaian pribadi ditaruh di file khusus user, jadi tidak hilang saat Caelestia di-update.

| Folder | Dipasang ke | Isi |
|---|---|---|
| `hypr/` | `~/.config/hypr` | Config Hyprland (format Lua), skema warna, script wallpaper |
| `caelestia/` | `~/.config/caelestia` | Setelan shell, override Hyprland, hook, template tema |
| `rofi/` | `~/.config/rofi` | Gaya popup bergaya Caelestia dan picker wallpaper |
| `local-bin/` | `~/.local/bin` | Script menu layar, baterai, audio, mic, tombol laptop |
| `system/` | `/etc`, `/usr/local` | Izin sudo, hook pacman, pembuat tema GRUB dan login |

## Cara Pasang

### 1. Pasang Caelestia dulu

Ikuti panduan resmi [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia). Repo ini hanya menimpa bagian yang dipersonalisasi.

### 2. Pasang paket yang dipakai

```bash
yay -S --needed rofi jq libnotify gnome-calculator pwvucontrol inotify-tools \
       equibop-bin spotify spicetify-cli zen-browser-bin visual-studio-code-bin \
       caelestia-sddm-locklike-git plymouth python-pillow ufw
```

Nama paket AUR bisa berubah. Cek dengan `yay -Ss <nama>` kalau ada yang tidak ditemukan.

### 3. Jalankan installer

```bash
git clone https://github.com/FelixStillLearning/caelestia-hypr-backup.git
cd caelestia-hypr-backup
./install.sh            # config user saja
./install.sh --system   # + tema login/GRUB, izin sudo, hook pacman (minta password)
```

Installer selalu membackup config lama ke `~/.config-backup-<tanggal>` sebelum menimpa. Setelah selesai, logout lalu login lagi.

### 4. Langkah manual (sekali saja)

Langkah ini menyentuh boot, jadi sengaja tidak diotomatiskan. Jalankan satu per satu.

**Tema GRUB.** Ganti resolusi kalau layarmu bukan 1920x1200:

```bash
sudo sed -i -e 's|^#GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/caelestia/theme.txt"|' \
            -e 's/^GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1200,auto/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Kalau dual boot dengan Windows, pastikan `GRUB_DISABLE_OS_PROBER=false` di `/etc/default/grub` dan output `grub-mkconfig` menyebut `Found Windows Boot Manager`.

**Animasi boot (Plymouth).** Logo pabrikan dengan putaran loading:

```bash
sudo sed -i 's/^HOOKS=(base systemd /HOOKS=(base systemd plymouth /' /etc/mkinitcpio.conf
sudo mkinitcpio -P
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**Layar login.** Pastikan tidak ada file lain di `/etc/sddm.conf.d/` yang memaksa tema lain (`Current=...`), lalu:

```bash
sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
```

**Discord.** Buka Equibop (`SUPER + D`), lalu buka Settings, pilih Themes, dan centang `caelestia.theme.css`.

**VS Code.** Tekan `Ctrl+K` lalu `Ctrl+T`, kemudian pilih **Caelestia**.

**Firewall.** Koneksi masuk ditolak, kecuali penemuan perangkat di jaringan lokal dan Spotify Connect:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 5353/udp comment 'mDNS: printer, Chromecast, Spotify Connect'
sudo ufw allow 57621 comment 'Spotify Connect'
sudo systemctl enable --now ufw
sudo ufw enable
```

## Fitur Tambahan

Fitur yang ditambahkan di atas Caelestia bawaan, dibuat supaya terasa seperti Windows:

| Fitur | Tombol | Keterangan |
|---|---|---|
| Menu mode layar | `F7` / `SUPER + P` | PC screen only, Duplicate, Extend, Second screen only. Pilihan diingat setelah restart dan dipakai lagi saat HDMI dicolok |
| Menu output dan input audio | `F11` | Pilih speaker, headphone, Bluetooth, atau mic. Suara yang sedang diputar ikut pindah |
| Mode pengisian baterai | `SUPER + ALT + B` | Fast, Standard, Long Life (berhenti di sekitar 80%) |
| Notifikasi mic | `F4` | Muncul pemberitahuan saat mic di-mute atau dinyalakan |
| Mode pesawat | `F8` | WiFi dan Bluetooth mati bersamaan, dengan notifikasi |
| Pengaturan Caelestia | `F9` / `SUPER + I` | Membuka aplikasi setelan Caelestia |
| Kalkulator | `F12` | GNOME Calculator |
| Tombol Copilot | `Copilot` | Membuka terminal dan langsung menjalankan Claude Code |
| Pin jendela | `SUPER + SHIFT + P` | Jendela tetap terlihat di semua workspace |

Semua popup memakai gaya Caelestia (font Rubik, ikon Material Symbols, sudut membulat) dan warnanya ikut wallpaper.

## Tema Seragam

Setiap kali wallpaper diganti (lewat `SUPER + W` atau menu Caelestia), warna di tempat-tempat ini ikut berubah:

| Bagian | Cara kerja |
|---|---|
| Menu GRUB | `caelestia-grub-theme` membuat latar blur, kartu menu, dan pill pilihan dari wallpaper |
| Layar login (SDDM) | Tema [caelestia-sddm](https://github.com/ItsABigIgloo/caelestia-sddm) Locklike, sapaan "Welcome back, sir." dari `caelestia-sddm-greeting` |
| Desktop, terminal, aplikasi GTK/Qt | Bawaan Caelestia |
| Popup rofi (F7, F11, baterai, wallpaper) | `sync-caelestia-rofi.py` |
| Discord (Equibop) | Bawaan Caelestia |
| Spotify | Spicetify, berlaku saat Spotify dibuka lagi |
| VS Code | Extension `caelestia-vscode-integration`, berubah langsung |
| Zen Browser | Template `caelestia/templates/zen-userChrome.css`, berlaku saat Zen dibuka lagi |

Penghubungnya ada di `caelestia/cli.json` (`postHook`). Izin sudo tanpa password hanya diberikan untuk dua script sinkronisasi itu (lihat `system/etc/sudoers.d/`). Kedua script membaca file user dengan hak user biasa.

## Spesifikasi Sistem

| Komponen | Detail |
|---|---|
| Laptop | Lenovo IdeaPad Slim 5 14AKP10 (83HX) |
| OS | Arch Linux (kernel 7.2), dual boot Windows |
| Compositor | Hyprland 0.57, config berbasis Lua |
| Shell desktop | Caelestia Shell 2.5 (Quickshell) |
| CPU / GPU | AMD Ryzen AI 7 350, Radeon 860M |
| Layar | `eDP-1` 1920x1200 @ 60 Hz |
| Shell terminal | fish (foot), zsh (login) |

## Struktur Repo

```text
.
├── install.sh                 # installer (backup otomatis)
├── caelestia/
│   ├── hypr-vars.lua          # override variabel Hyprland (aplikasi default, keybind)
│   ├── hypr-user.lua          # tambahan pribadi: mode layar, F-key, Copilot, autostart
│   ├── cli.json               # Discord via Equibop + hook sinkronisasi tema
│   ├── templates/             # template warna untuk layar login dan Zen
│   ├── shell.json             # setelan Caelestia Shell
│   ├── monitors/eDP-1/        # setelan shell per monitor
│   └── user-config.fish       # tambahan config fish
├── hypr/
│   ├── hyprland.lua           # entrypoint utama (bawaan Caelestia)
│   ├── variables.lua          # nilai default (bawaan Caelestia)
│   ├── hyprland/              # modul: env, input, rules, keybinds, dll.
│   ├── scheme/                # skema warna (dibuat otomatis dari wallpaper)
│   ├── utils/                 # helper Lua
│   └── scripts/               # picker wallpaper (SUPER + W) dan ganti wallpaper acak
├── rofi/
│   ├── caelestia-menu.rasi    # gaya popup F7 / F11 / baterai
│   ├── wallpaper-picker.rasi  # gaya picker wallpaper
│   └── colors.rasi            # warna (ditulis ulang otomatis)
├── local-bin/
│   ├── display-mode.sh        # menu mode layar
│   ├── audio-menu.sh          # menu output/input audio
│   ├── battery-mode.sh        # menu mode pengisian baterai
│   ├── mic-watch.sh           # notifikasi mute mic
│   ├── lenovo-keys.py         # tombol F11 Lenovo
│   ├── airplane-mode.sh       # mode pesawat (F8)
│   ├── toggle-touchpad.sh     # touchpad on/off
│   ├── rofi-icon              # ikon Material Symbols untuk rofi
│   └── sync-caelestia-rofi.py # salin warna Caelestia ke rofi
└── system/
    ├── etc/sudoers.d/         # izin sudo tanpa password (%USER% diganti installer)
    ├── etc/pacman.d/hooks/    # pasang ulang sapaan login setelah tema di-update
    ├── etc/modprobe.d/        # perbaikan mic AMD (khusus laptop tertentu)
    └── usr/local/             # caelestia-grub-theme, caelestia-sddm-greeting, font Rubik GRUB
```

## Cara Kerja Config

`hyprland.lua` adalah titik masuknya. Urutan yang dijalankan:

1. Jika `scheme/current.lua` belum ada, salin dari `scheme/default.lua`.
2. Timpa nilai di `variables.lua` dengan isi `~/.config/caelestia/hypr-vars.lua`.
3. Pasang monitor default (`preferred`, posisi `auto`, scale `1`).
4. Muat modul di `hyprland/` satu per satu.
5. Terakhir, muat `~/.config/caelestia/hypr-user.lua` untuk tambahan pribadi.

Jangan edit file di `hypr/` secara langsung, karena file-file itu ditimpa saat Caelestia di-update. Taruh perubahan di **`caelestia/hypr-vars.lua`** atau **`caelestia/hypr-user.lua`**.

## Aplikasi Default

| Peran | Aplikasi |
|---|---|
| Terminal | `foot` |
| Browser | `zen-browser` |
| Editor | `code` (VS Code) |
| File manager | `thunar` |
| Discord | `equibop` |
| Pengaturan audio | `pwvucontrol` |
| Kalkulator | `gnome-calculator` |
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

## Keybind

`SUPER` adalah tombol Windows. Tombol F di bawah adalah fungsi khusus (gambar di tombol). Tekan `Fn + Esc` untuk menukar perilakunya dengan F1–F12 biasa.

### Aplikasi dan Shell

| Shortcut | Aksi |
|---|---|
| `SUPER` (tekan lalu lepas) | Launcher Caelestia |
| `SUPER + Enter` | Terminal |
| `SUPER + SHIFT + Enter` | Terminal mengambang |
| `SUPER + B` | Browser |
| `SUPER + C` | Editor |
| `SUPER + E` | File manager |
| `SUPER + D` | Discord (special workspace) |
| `SUPER + W` | Pilih wallpaper |
| `SUPER + I` / `F9` | Pengaturan Caelestia |
| `SUPER + N` | Sidebar notifikasi |
| `SUPER + K` | Tampilkan semua panel |
| `Copilot` | Terminal + Claude Code |
| `CTRL + ALT + Delete` | Menu sesi (logout, restart, shutdown) |
| `CTRL + ALT + V` | Pengaturan audio lengkap |

### Jendela

| Shortcut | Aksi |
|---|---|
| `SUPER + Q` | Tutup jendela |
| `SUPER + F` | Fullscreen |
| `SUPER + ALT + F` | Maximize (tetap ada border) |
| `SUPER + ALT + Space` | Floating on/off |
| `SUPER + SHIFT + P` | Pin jendela |
| `SUPER + ALT + \` | Mode picture-in-picture |
| `CTRL + SUPER + \` | Taruh jendela di tengah |
| `SUPER + Panah` | Pindah fokus |
| `SUPER + SHIFT + Panah` | Pindahkan jendela |
| `SUPER + -` / `SUPER + =` | Ubah lebar |
| `SUPER + Klik kiri` / `SUPER + Z` | Geser jendela |
| `SUPER + Klik kanan` / `SUPER + X` | Ubah ukuran jendela |
| `ALT + Tab` | Ke jendela sebelumnya |

### Workspace

| Shortcut | Aksi |
|---|---|
| `SUPER + 1..0` | Ke workspace 1 sampai 10 |
| `SUPER + ALT + 1..0` | Pindahkan jendela ke workspace |
| `SUPER + Scroll` / `SUPER + Page Up/Down` | Workspace sebelumnya / berikutnya |
| `SUPER + S` | Special workspace |
| `SUPER + M` | Workspace musik (Spotify) |
| `SUPER + R` | Workspace todo |
| `CTRL + SHIFT + Escape` | Workspace system monitor |
| Swipe 3 jari | Ganti workspace |

### Utilitas dan Tombol Laptop

| Shortcut | Aksi |
|---|---|
| `F4` | Mute mic (dengan notifikasi) |
| `F7` / `SUPER + P` | Menu mode layar |
| `F8` | Mode pesawat |
| `F11` | Menu output/input audio |
| `F12` | Kalkulator |
| `SUPER + ALT + B` | Mode pengisian baterai |
| `Print` | Screenshot penuh |
| `SUPER + SHIFT + S` | Screenshot area (layar dibekukan) |
| `CTRL + ALT + R` | Rekam layar |
| `SUPER + ALT + R` | Rekam layar dengan suara |
| `SUPER + SHIFT + C` | Color picker |
| `SUPER + V` | Riwayat clipboard |
| `SUPER + .` | Pemilih emoji |
| `SUPER + L` | Kunci layar |
| `SUPER + ALT + T` | Touchpad on/off |

### Darurat

| Shortcut | Aksi |
|---|---|
| `CTRL + SUPER + ALT + R` | Restart Caelestia Shell |
| `SUPER + ALT + L` | Pulihkan layar kunci jika shell crash |

Daftar lengkap keybind bawaan ada di `hypr/variables.lua` bagian `KEYBINDS`.

## Autostart

Bawaan Caelestia (`hypr/hyprland/execs.lua`): gnome-keyring, polkit, cliphist, trash-empty, cursor, gammastep, mpris-proxy, dan `caelestia shell -d`.

Tambahan dari `caelestia/hypr-user.lua`:

- `mic-watch.sh`: notifikasi saat mic di-mute atau dinyalakan
- `lenovo-keys.py`: membaca tombol F11 Lenovo yang tidak dikenali driver
- Mode layar terakhir dipasang ulang saat login dan saat monitor dicolok/dicabut

## Khusus Perangkat Keras

Bagian ini dibuat untuk Lenovo IdeaPad Slim 5 AMD. Di laptop lain, bagian-bagian ini tidak merusak apa pun, hanya tidak berfungsi:

| Bagian | Catatan |
|---|---|
| `lenovo-keys.py` (F11) | Hanya untuk perangkat "Ideapad extra buttons". Di laptop lain script ini langsung berhenti |
| Mode baterai | Butuh `/sys/class/power_supply/BAT0/charge_types` (driver ideapad). Laptop lain bisa beda nama atau tidak punya |
| Perbaikan mic (`blacklist-amd-dmic.conf`) | **Hanya** untuk IdeaPad Slim 5 AMD yang mic internalnya tidak menangkap suara. Mic digital AMD dimatikan supaya mic analog Conexant dipakai. Lihat [alsa-ucm-conf#612](https://github.com/alsa-project/alsa-ucm-conf/issues/612). Installer menanyakan dulu sebelum memasang |
| Tombol Copilot | Dibaca sebagai `SUPER + SHIFT + code:201`. Keyboard lain bisa berbeda |
| Resolusi tema GRUB | Diatur untuk 1920x1200. Ganti `GRUB_GFXMODE` sesuai layarmu |

## Catatan

- `hypr/scheme/current.*`, `rofi/colors.rasi`, dan file di `~/.local/state/caelestia/theme/` dibuat ulang otomatis setiap ganti wallpaper. Jangan diedit manual.
- Picker wallpaper (`SUPER + W`) mengambil gambar dari `~/Pictures/wallpapers`.
- Kalau tema Spotify hilang setelah Spotify di-update, jalankan `spicetify backup apply`.
- Kalau sapaan login kembali besar setelah update tema, jalankan `sudo caelestia-sddm-greeting`. Biasanya ini sudah otomatis lewat hook pacman.

## Kredit

- [caelestia-dots](https://github.com/caelestia-dots) oleh [soramanew](https://github.com/soramanew): shell dan struktur dotfiles yang menjadi dasar setup ini
- [caelestia-sddm](https://github.com/ItsABigIgloo/caelestia-sddm) oleh ItsABigIgloo: tema layar login
- [Hyprland](https://hyprland.org)
- [Quickshell](https://quickshell.org)
