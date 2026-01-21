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
        --config-file="$USER_HOME/.config/alacritty/alacritty_non_opaque.toml" \
        --class alacritty_floating \
        --title "Floating Terminal" \
        --working-directory "$USER_HOME" \
        -e bash -c "sudo journalctl -f"
}

# menu: System | 📊 investigate Process Stats
sys_investigate_process_stats() {
	alacritty -e zsh -c "source ~/.zshrc && investigate_processes"
}


"$@"
