# caelestia-hypr-backup

Dotfiles Hyprland (config Lua) dan Caelestia Shell untuk Arch Linux, dipakai di Lenovo IdeaPad Slim 5 14AKP10 (AMD).

Repo ini berisi lapisan kustomisasi di atas [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia): tema yang mengikuti wallpaper dari GRUB sampai aplikasi, beberapa menu bergaya Windows, perbaikan khusus perangkat keras, dan asisten suara Jarvis yang berjalan offline.

## Daftar isi

- [Kebutuhan](#kebutuhan)
- [Instalasi](#instalasi)
- [Langkah manual](#langkah-manual)
- [Sinkronisasi tema](#sinkronisasi-tema)
- [Fitur tambahan](#fitur-tambahan)
- [Jarvis](#jarvis)
- [KDE Connect](#kde-connect)
- [Struktur repo](#struktur-repo)
- [Cara kerja config](#cara-kerja-config)
- [Keybind](#keybind)
- [Autostart](#autostart)
- [Catatan perangkat keras](#catatan-perangkat-keras)
- [Pemecahan masalah](#pemecahan-masalah)
- [Kredit](#kredit)

## Kebutuhan

| Komponen | Versi yang dipakai |
|---|---|
| OS | Arch Linux, kernel 7.2 |
| Compositor | Hyprland 0.57 (config Lua) |
| Shell desktop | Caelestia Shell 2.5 (Quickshell) |
| CPU / GPU | AMD Ryzen AI 7 350, Radeon 860M |
| Layar | `eDP-1` 1920x1200 @ 60 Hz |

Caelestia harus sudah terpasang sesuai [panduan resminya](https://github.com/caelestia-dots/caelestia). Installer di repo ini hanya menimpa bagian yang dikustomisasi.

## Instalasi

Paket tambahan:

```bash
yay -S --needed rofi jq libnotify gnome-calculator pwvucontrol inotify-tools ffmpeg \
       equibop-bin spotify spicetify-cli zen-browser-bin visual-studio-code-bin \
       caelestia-sddm-locklike-git plymouth python-pillow ufw kdeconnect
```

Nama paket AUR bisa berubah; cek dengan `yay -Ss <nama>` bila ada yang tidak ditemukan.

```bash
git clone https://github.com/FelixStillLearning/caelestia-hypr-backup.git
cd caelestia-hypr-backup
./install.sh            # config user
./install.sh --system   # ditambah file sistem: sudoers, hook pacman, tema GRUB/login, Zen, firewall KDE Connect
```

Config lama dibackup ke `~/.config-backup-<tanggal>` sebelum ditimpa. Installer aman dijalankan ulang. Logout lalu login kembali setelah selesai.

Yang dilakukan `install.sh`:

- Menyalin `hypr/`, `caelestia/`, `rofi/` ke `~/.config` dan `local-bin/` ke `~/.local/bin`.
- Zen Browser: memasang `userChrome.css` dan startpage untuk setiap profil.
- Obsidian: memasang snippet `caelestia` di setiap vault. Vault yang disinkron git otomatis mengabaikan snippet ini.
- VS Code: memasang extension `caelestia-vscode-integration`.
- Spotify: menerapkan tema lewat Spicetify.
- Opsional: mengunduh Piper TTS dan model suara Jarvis (sekitar 300 MB).

## Langkah manual

Langkah berikut menyentuh proses boot, sehingga tidak diotomatiskan. Jalankan satu per satu.

**Tema GRUB.** Sesuaikan resolusi bila layar bukan 1920x1200.

```bash
sudo sed -i -e 's|^#GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/caelestia/theme.txt"|' \
            -e 's/^GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1200,auto/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Untuk dual boot Windows, set `GRUB_DISABLE_OS_PROBER=false` dan pastikan output `grub-mkconfig` menampilkan `Found Windows Boot Manager`. Tambahkan juga `GRUB_DISABLE_BOOTNEXT=true` supaya menu tidak penuh entri UEFI.

**Plymouth.**

```bash
sudo sed -i 's/^HOOKS=(base systemd /HOOKS=(base systemd plymouth /' /etc/mkinitcpio.conf
sudo mkinitcpio -P
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**Layar login.** Pastikan tidak ada file di `/etc/sddm.conf.d/` yang menetapkan `Current=` ke tema lain, lalu:

```bash
sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
```

**Firewall.**

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 5353/udp comment 'mDNS'
sudo ufw allow 57621 comment 'Spotify Connect'
sudo systemctl enable --now ufw
sudo ufw enable
```

**Aplikasi.**

- Equibop: Settings > Themes, aktifkan `caelestia.theme.css`.
- VS Code: `Ctrl+K Ctrl+T`, pilih Caelestia.
- Zen: tutup lalu buka kembali agar `userChrome.css` dan startpage terbaca.

## Sinkronisasi tema

Setiap pergantian wallpaper (`SUPER + W` atau menu Caelestia) memperbarui warna di:

| Target | Mekanisme |
|---|---|
| Menu GRUB | `caelestia-grub-theme`: latar blur, kartu menu, dan font Rubik dibuat dari wallpaper |
| Layar login | Tema [caelestia-sddm](https://github.com/ItsABigIgloo/caelestia-sddm) Locklike, sapaan diganti oleh `caelestia-sddm-greeting` |
| Desktop, terminal, GTK/Qt, Discord | Bawaan Caelestia |
| Popup rofi | `sync-caelestia-rofi.py` |
| Spotify | Spicetify, berlaku saat Spotify dibuka ulang |
| VS Code | Extension `caelestia-vscode-integration` |
| Zen Browser | `templates/zen-userChrome.css` dan startpage `templates/startpage.html` |
| Obsidian | `templates/obsidian-caelestia.css` |

Template di `caelestia/templates/` dirender Caelestia ke `~/.local/state/caelestia/theme/`. Hook pasca-ganti tema didefinisikan di `caelestia/cli.json`. Izin sudo tanpa password hanya diberikan untuk script sinkronisasi GRUB dan SDDM (lihat `system/etc/sudoers.d/`).

## Fitur tambahan

| Fitur | Tombol | Keterangan |
|---|---|---|
| Mode layar | `F7` / `SUPER + P` | PC screen only, Duplicate, Extend, Second screen only. Pilihan disimpan dan dipakai ulang saat monitor dicolok |
| Output dan input audio | `F11` | Speaker, headphone, Bluetooth, mic. Stream yang berjalan ikut dipindah |
| Mode pengisian baterai | `SUPER + ALT + B` | Fast, Standard, Long Life (berhenti sekitar 80%) |
| Notifikasi mic | `F4` | Notifikasi saat mic dimatikan atau dinyalakan |
| Mode pesawat | `F8` | WiFi dan Bluetooth dimatikan bersamaan |
| Pengaturan Caelestia | `F9` / `SUPER + I` | |
| Kalkulator | `F12` | GNOME Calculator |
| Tombol Copilot | `Copilot` | Terminal dengan Claude Code |
| Briefing Jarvis | `SUPER + J` | Lihat [Jarvis](#jarvis) |

Perubahan lain:

- Jam desktop dan visualizer audio di wallpaper (`caelestia/shell.json`).
- Spotify menjadi pemutar default di panel media, sehingga aplikasi lain yang mendaftar MPRIS (misalnya Ferdium) tidak mengambil alih.
- Startpage Zen untuk homepage dan tab baru: jam, kolom pencarian, dan shortcut. Daftar shortcut ada di variabel `LINKS` pada `caelestia/templates/startpage.html`.
- Share screen: kursor ikut terekam (`cursor:no_hardware_cursors`) dan dialog pemilihan layar tidak muncul dua kali (`hypr/xdph.conf`).

## Jarvis

Asisten suara offline berbasis [Piper TTS](https://github.com/OHF-Voice/piper1-gpl) dengan model komunitas [jgkawell/jarvis](https://huggingface.co/jgkawell/jarvis) dan sedikit efek gema dari `ffmpeg`.

| Perintah | Fungsi |
|---|---|
| `jarvis greet` | Sapaan sesuai waktu, diputar saat login |
| `jarvis brief` | Jam, cuaca ([wttr.in](https://wttr.in)), baterai, dan lagu yang diputar. Dipanggil oleh `SUPER + J` |
| `jarvis battery` | Daemon: charger dicolok/dicabut serta baterai 20%, 10%, dan 5% |
| `jarvis say "teks"` | Mengucapkan teks bebas |

Lokasi file: `~/.local/share/piper/venv` (Piper) dan `~/.local/share/piper/voices` (model). Model suara tidak disertakan di repo; installer mengunduhnya bila dipilih.

## KDE Connect

Menghubungkan ponsel Android lewat jaringan lokal: notifikasi, clipboard bersama, kirim file, dan kontrol media. `kdeconnectd` dan `kdeconnect-indicator` dijalankan dari `hypr-user.lua`, karena autostart XDG tidak aktif di sesi ini.

1. Pasang aplikasi KDE Connect di ponsel dan sambungkan ke jaringan yang sama.
2. Buka port 1714-1764 TCP/UDP (otomatis lewat `./install.sh --system` bila `ufw` terpasang).
3. Pilih laptop di aplikasi ponsel, minta pairing, lalu terima di laptop.

Izin plugin yang cukup di ponsel: Notification sync, Telephony notifier, Contacts Synchronizer, Filesystem access.

## Struktur repo

```text
.
├── install.sh
├── caelestia/
│   ├── hypr-vars.lua          # override variabel Hyprland (aplikasi default, keybind)
│   ├── hypr-user.lua          # tambahan: mode layar, F-key, Jarvis, KDE Connect, autostart
│   ├── cli.json               # Discord via Equibop dan hook sinkronisasi tema
│   ├── shell.json             # setelan Caelestia Shell
│   ├── templates/             # SDDM, Zen, startpage, Obsidian
│   ├── monitors/eDP-1/        # setelan shell per monitor
│   └── user-config.fish
├── hypr/
│   ├── hyprland.lua           # entrypoint (bawaan Caelestia)
│   ├── variables.lua          # nilai default (bawaan Caelestia)
│   ├── xdph.conf              # setelan portal share screen
│   ├── hyprland/              # modul: env, input, rules, keybinds
│   ├── scheme/                # skema warna, dibuat dari wallpaper
│   ├── utils/
│   └── scripts/               # picker dan pengganti wallpaper
├── rofi/                      # gaya popup dan picker wallpaper
├── local-bin/                 # menu layar, audio, baterai, mic, tombol laptop, jarvis
└── system/
    ├── etc/sudoers.d/         # %USER% diganti oleh installer
    ├── etc/pacman.d/hooks/    # pasang ulang sapaan login setelah update tema
    ├── etc/modprobe.d/        # perbaikan mic AMD
    ├── opt/zen-browser-bin/   # autoconfig untuk tab baru Zen
    └── usr/local/             # caelestia-grub-theme, caelestia-sddm-greeting, font GRUB
```

## Cara kerja config

`hypr/hyprland.lua` memuat config dengan urutan:

1. Menyalin `scheme/default.lua` ke `scheme/current.lua` bila belum ada.
2. Menimpa `variables.lua` dengan `~/.config/caelestia/hypr-vars.lua`.
3. Mengatur monitor default.
4. Memuat modul di `hyprland/`.
5. Memuat `~/.config/caelestia/hypr-user.lua`.

File di `hypr/` ditimpa saat Caelestia diperbarui. Simpan perubahan di `caelestia/hypr-vars.lua` atau `caelestia/hypr-user.lua`.

## Keybind

`SUPER` adalah tombol Windows. Tombol F memakai fungsi khusus secara default; `Fn + Esc` menukarnya dengan F1 sampai F12.

### Aplikasi dan shell

| Shortcut | Aksi |
|---|---|
| `SUPER` | Launcher |
| `SUPER + Enter` | Terminal |
| `SUPER + SHIFT + Enter` | Terminal mengambang |
| `SUPER + B` | Browser |
| `SUPER + C` | Editor |
| `SUPER + E` | File manager |
| `SUPER + D` | Discord (special workspace) |
| `SUPER + W` | Pemilih wallpaper |
| `SUPER + I` / `F9` | Pengaturan Caelestia |
| `SUPER + N` | Sidebar notifikasi |
| `SUPER + K` | Semua panel |
| `SUPER + J` | Briefing Jarvis |
| `Copilot` | Terminal dengan Claude Code |
| `CTRL + ALT + Delete` | Menu sesi |
| `CTRL + ALT + V` | Pengaturan audio |

### Jendela

| Shortcut | Aksi |
|---|---|
| `SUPER + Q` | Tutup |
| `SUPER + F` | Fullscreen |
| `SUPER + ALT + F` | Maximize dengan border |
| `SUPER + ALT + Space` | Floating |
| `SUPER + SHIFT + P` | Pin |
| `SUPER + ALT + \` | Picture-in-picture |
| `CTRL + SUPER + \` | Ke tengah layar |
| `SUPER + Panah` | Pindah fokus |
| `SUPER + SHIFT + Panah` | Pindahkan jendela |
| `SUPER + -` / `SUPER + =` | Ubah lebar |
| `SUPER + klik kiri` / `SUPER + Z` | Geser |
| `SUPER + klik kanan` / `SUPER + X` | Ubah ukuran |
| `ALT + Tab` | Jendela sebelumnya |

### Workspace

| Shortcut | Aksi |
|---|---|
| `SUPER + 1..0` | Workspace 1 sampai 10 |
| `SUPER + ALT + 1..0` | Pindahkan jendela ke workspace |
| `SUPER + scroll` / `SUPER + Page Up/Down` | Workspace sebelumnya / berikutnya |
| `SUPER + S` | Special workspace |
| `SUPER + M` | Workspace musik |
| `SUPER + R` | Workspace todo |
| `CTRL + SHIFT + Escape` | System monitor |
| Geser 3 jari | Ganti workspace |

### Utilitas

| Shortcut | Aksi |
|---|---|
| `F4` | Mute mic |
| `F7` / `SUPER + P` | Mode layar |
| `F8` | Mode pesawat |
| `F11` | Output/input audio |
| `F12` | Kalkulator |
| `SUPER + ALT + B` | Mode pengisian baterai |
| `Print` | Screenshot layar penuh |
| `SUPER + SHIFT + S` | Screenshot area |
| `CTRL + ALT + R` | Rekam layar |
| `SUPER + ALT + R` | Rekam layar dengan audio |
| `SUPER + SHIFT + C` | Color picker |
| `SUPER + V` | Riwayat clipboard |
| `SUPER + .` | Emoji |
| `SUPER + L` | Kunci layar |
| `SUPER + ALT + T` | Touchpad on/off |
| `CTRL + SUPER + ALT + R` | Restart Caelestia Shell |
| `SUPER + ALT + L` | Pulihkan layar kunci bila shell crash |

Keybind bawaan lengkap ada di `hypr/variables.lua` bagian `KEYBINDS`.

## Autostart

Bawaan Caelestia (`hypr/hyprland/execs.lua`): gnome-keyring, polkit, cliphist, trash-empty, cursor, gammastep, mpris-proxy, `caelestia shell -d`.

Tambahan dari `caelestia/hypr-user.lua`:

- `mic-watch.sh`: notifikasi status mic
- `lenovo-keys.py`: membaca tombol F11 yang tidak dikenali driver
- `jarvis greet` dan `jarvis battery`
- `kdeconnectd` dan `kdeconnect-indicator`
- Mode layar terakhir diterapkan saat login dan saat monitor berubah

## Catatan perangkat keras

Bagian berikut ditujukan untuk IdeaPad Slim 5 AMD. Di perangkat lain bagian ini tidak berfungsi, tetapi tidak merusak apa pun.

| Bagian | Catatan |
|---|---|
| `lenovo-keys.py` | Hanya untuk perangkat input "Ideapad extra buttons"; berhenti sendiri bila tidak ditemukan |
| Mode baterai, Jarvis battery | Membaca `/sys/class/power_supply/BAT0` dan `ACAD` (driver ideapad) |
| `blacklist-amd-dmic.conf` | Hanya untuk unit yang mic internalnya tidak menangkap suara. Mic digital AMD dinonaktifkan agar mic analog Conexant dipakai. Referensi: [alsa-ucm-conf#612](https://github.com/alsa-project/alsa-ucm-conf/issues/612). Installer meminta konfirmasi |
| Tombol Copilot | Terbaca sebagai `SUPER + SHIFT + code:201` |
| Tema GRUB | Dibuat untuk 1920x1200; sesuaikan `GRUB_GFXMODE` |

## Pemecahan masalah

| Gejala | Solusi |
|---|---|
| Tema Spotify hilang setelah update | `spicetify backup apply` |
| Sapaan login kembali ke bawaan | `sudo caelestia-sddm-greeting` (biasanya otomatis lewat hook pacman) |
| Tab baru Zen tidak memakai startpage | Jalankan `./install.sh --system`, lalu tutup Zen sepenuhnya dan buka ulang |
| Panel media menampilkan "Unknown artist" | Pilih Spotify lewat tombol pemutar di panel media |
| Jarvis tidak bersuara | Cek `~/.local/share/piper/voices/jarvis-high.onnx` ada dan `ffmpeg` terpasang; coba `jarvis say test` |

File `hypr/scheme/current.*`, `rofi/colors.rasi`, dan isi `~/.local/state/caelestia/theme/` dibuat ulang setiap ganti wallpaper; jangan diedit langsung. Pemilih wallpaper membaca `~/Pictures/wallpapers`.

## Kredit

- [caelestia-dots](https://github.com/caelestia-dots) oleh [soramanew](https://github.com/soramanew)
- [caelestia-sddm](https://github.com/ItsABigIgloo/caelestia-sddm) oleh ItsABigIgloo
- [Piper](https://github.com/OHF-Voice/piper1-gpl) dan model suara [jgkawell/jarvis](https://huggingface.co/jgkawell/jarvis)
- [Hyprland](https://hyprland.org), [Quickshell](https://quickshell.org)
