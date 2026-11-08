local vars   = require("variables")
local locked = { locked = true }

-- ALT+TAB: kembali ke window terakhir
hl.bind("ALT + TAB", hl.dsp.focus({ last = true }), { repeating = true })

-- Terminal float
hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd("[float; size 800 550] " .. vars.terminal))

-- Wallpaper picker
hl.bind("SUPER + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wppicker.sh"))

-- Toggle touchpad
for _, k in ipairs({ "SUPER + ALT + T", "XF86TouchpadToggle", "XF86TouchpadOff" }) do
    hl.bind(k, hl.dsp.exec_cmd("~/.local/bin/toggle-touchpad.sh"), locked)
end

-- File chooser (portal) di tengah
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true,
    size = "(monitor_w*0.6) (monitor_h*0.7)", center = true, pin = true })

-- Mode layar ala Win+P (SUPER+P / F7), pilihan diingat di ~/.local/state/display-mode
local LAPTOP        = "eDP-1"
local display_state = os.getenv("HOME") .. "/.local/state/display-mode"

local function read_mode()
    local f = io.open(display_state)
    local m = f and f:read("l")
    if f then f:close() end
    return m or "extend"
end

-- Semua port eksternal (HDMI, USB-C) beserta statusnya
local function connectors()
    local list, p = {}, io.popen("ls -d /sys/class/drm/card*-* 2>/dev/null")
    for dir in p:lines() do
        local name = dir:match("card%d+%-(.+)$")
        if name and name ~= LAPTOP and not name:match("^Writeback") then
            local f = io.open(dir .. "/status")
            list[#list + 1] = { name = name, connected = f and f:read("l") == "connected" }
            if f then f:close() end
        end
    end
    p:close()
    return list
end

-- skip: nama monitor yang baru dicabut (sysfs bisa belum update)
local function apply_display(mode, skip)
    local any_ext = false
    for _, c in ipairs(connectors()) do
        if c.connected and c.name ~= skip then any_ext = true end
        hl.monitor({ output = c.name, mode = "preferred", position = "auto", scale = 1,
            mirror = mode == "mirror" and LAPTOP or "", disabled = mode == "laptop" })
    end
    -- Layar laptop hanya dimatikan kalau memang ada layar eksternal tercolok
    hl.monitor({ output = LAPTOP, mode = "preferred", position = "auto", scale = 1,
        mirror = "", disabled = mode == "external" and any_ext })
end

-- Dipanggil dari ~/.local/bin/display-mode.sh lewat `hyprctl eval`
function DisplayMode(mode)
    local f = io.open(display_state, "w")
    if f then f:write(mode, "\n"); f:close() end
    apply_display(mode)
end

apply_display(read_mode())
hl.on("monitor.added", function() apply_display(read_mode()) end)
hl.on("monitor.removed", function(m) apply_display(read_mode(), m and m.name) end)

hl.bind("SUPER + P", hl.dsp.exec_cmd("~/.local/bin/display-mode.sh")) -- juga tombol F7
hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd("~/.local/bin/battery-mode.sh"))

-- Notifikasi saat mic di-mute/unmute
hl.on("hyprland.start", function() hl.exec_cmd("~/.local/bin/mic-watch.sh") end)

-- Tombol Copilot: kernel kirim SUPER+SHIFT+F23 (kode fisik 201): buka terminal + Claude
hl.bind("SUPER + SHIFT + code:201", hl.dsp.exec_cmd(vars.terminal .. " zsh -ic 'claude; exec zsh'"))

-- F11: menu audio output/input, ditangani ~/.local/bin/lenovo-keys.py (scancode 0x148)
hl.on("hyprland.start", function() hl.exec_cmd("~/.local/bin/lenovo-keys.py") end)
-- F12: kalkulator
hl.bind("XF86Calculator", hl.dsp.exec_cmd("gnome-calculator"))
-- F8: mode pesawat
hl.bind("XF86RFKill", hl.dsp.exec_cmd("~/.local/bin/airplane-mode.sh"), locked)
-- F9 (gerigi): pengaturan Caelestia (Nexus)
hl.bind("SUPER + I", hl.dsp.exec_cmd("caelestia shell nexus open"))

-- Kursor ikut terlihat saat share screen (Discord/Chrome tidak menangkap hardware cursor)
hl.config({ cursor = { no_hardware_cursors = 1 } })

-- Jarvis: sambutan login, briefing Super+J, daemon pemantau (baterai, suhu, perangkat, lock, shutdown, jam)
hl.on("hyprland.start", function()
    hl.exec_cmd("sleep 3; ~/.local/bin/jarvis greet")
    hl.exec_cmd("~/.local/bin/jarvis watch")
    hl.exec_cmd("~/.local/bin/jarvis listen") -- "Hey Jarvis", perintah suara, ngobrol
end)
hl.bind("SUPER + J", hl.dsp.exec_cmd("~/.local/bin/jarvis brief"))
hl.bind("SUPER + SHIFT + J", hl.dsp.exec_cmd("~/.local/bin/jarvis ask")) -- bicara tanpa "Hey Jarvis"
hl.bind("SUPER + ALT + J", hl.dsp.exec_cmd("~/.local/bin/jarvis toggle")) -- nyalakan/matikan "Hey Jarvis"

-- KDE Connect: daemon + ikon di tray (kirim file, ring phone, dsb.)
hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/bin/kdeconnectd")
    hl.exec_cmd("sleep 2; kdeconnect-indicator")
end)

-- Transparansi per aplikasi (aktif / tidak aktif). Video dan gambar tetap solid.
for class, op in pairs({
    ["Spotify"]  = "0.85 override 0.80 override",
    ["equibop"]  = "0.88 override 0.82 override",
    ["code"]     = "0.92 override 0.88 override",
    ["obsidian"] = "0.92 override 0.88 override",
}) do
    hl.window_rule({ match = { class = class, fullscreen = false }, opaque = false, opacity = op })
end
hl.window_rule({ match = { class = "mpv|vlc|celluloid|imv|org.gnome.Loupe" }, opaque = true })

-- Poni Jarvis (Quickshell terpisah, ~/.config/quickshell/jarvis-island)
hl.layer_rule({ match = { namespace = "jarvis-island" }, blur = true, ignore_alpha = 0.3, animation = "fade" })
hl.on("hyprland.start", function() hl.exec_cmd("qs -c jarvis-island") end)
