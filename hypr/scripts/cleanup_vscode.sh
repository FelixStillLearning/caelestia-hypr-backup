#!/bin/bash
# Auto cleanup VSCode lock files on startup
pkill -9 code 2>/dev/null
rm -rf ~/.config/Code/User/workspaceStorage/*/state.vscdb.lock 2>/dev/null
rm -rf ~/.config/Code/User/workspaceStorage/*/.lock 2>/dev/null
sleep 1
exit 0
