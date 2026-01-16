#!/bin/bash
# system_functions.sh - System utilities

follow_journalctl() {
    alacritty \
        --config-file="$USER_HOME/.config/alacritty/alacritty_non_opaque.toml" \
        --class alacritty_floating \
        --title "Floating Terminal" \
        --working-directory "$USER_HOME" \
        -e bash -c "sudo journalctl -f"
}
