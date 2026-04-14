#!/bin/bash

# --- CATEGORY: SWAYR WINDOW MANAGEMENT ---
# menu: Window Management - swayr | 🥷 Steal window
win_swayr_steal() { swayr steal-window; }

# menu: Window Management - swayr | 🔄 Switch window
win_swayr_switch() { swayr switch-window; }

# menu: Window Management - swayr | 📑 Switch workspace
win_swayr_work() { swayr switch-workspace; }

# menu: Window Management - swayr | 📦 Move focused to workspace
win_swayr_move() { swayr move-focused-to-workspace; }


# Only run dispatcher if executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
