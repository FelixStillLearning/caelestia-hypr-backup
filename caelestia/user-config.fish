
# Jarvis: umumkan perintah yang jalan lebih dari 30 detik saat terminalnya tidak sedang dilihat
function __jarvis_done --on-event fish_postexec
    set -l s $status
    test $CMD_DURATION -gt 30000; and command -q jarvis; or return
    jarvis done $s $fish_pid $argv[1] >/dev/null 2>&1 &
    disown
end
