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


"$@"
