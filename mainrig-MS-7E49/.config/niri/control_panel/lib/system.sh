#!/bin/bash

# --- CATEGORY: SYSTEM ---
# menu: System | 🚀 Start dotoold
# dotoold_manager.sh - Manages dotoold daemon
sys_dotoold_start() {
    pgrep -x dotoold >/dev/null || (nohup dotoold >/dev/null 2>&1 & echo "dotoold started")
}

# menu: System | 📜 Follow Journalctl
# system_functions.sh - System utilities
sys_journal_follow() {
    alacritty \
        --config-file="$USER_HOME/.config/alacritty/alacritty.toml" \
        --class alacritty_floating \
        --title "Floating Terminal" \
        --working-directory "$USER_HOME" \
        -e bash -c "sudo journalctl -f"
}

# menu: System | 🔁 Restart Audio/PipeWire/Wireplumber 
sys_restart_pipewire() { 
    if bash -lc 'systemctl --user restart pipewire wireplumber'; then
        notify-send "Audio" "Audio services restarted successfully"
    else
        notify-send -u critical "Audio" "PipeWire restart failed"
    fi
}

# menu: System | 💤 Suspend System
sys_suspend() {
	source ${USER_HOME}/scripts/functions/suspend
	_suspend
}

# Only run dispatcher if executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
