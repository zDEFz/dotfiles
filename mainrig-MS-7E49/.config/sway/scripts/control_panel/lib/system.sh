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

# menu: System | 🖥 Print System Specs
sys_print_specs() {

    # 1. Generate clean text
    # Added a filter to strip cursor control codes and ANSI colors
    TEXT=$(neofetch --off \
             --disable resolution \
             --disable shell \
             --disable theme \
             --disable icons \
             --disable terminal \
             --disable underline \
             --color_blocks off | sed -e 's/\x1b\[[0-9;?]*[a-zA-Z]//g')

    # 2. Copy to clipboard
    echo "$TEXT" | wl-copy

    # 3. Paste
    echo 'key ctrl+v' | dotoolc
}


"$@"
