#!/bin/bash

# --- CATEGORY: SWAYR WINDOW MANAGEMENT ---
# menu: Swayr Window Management | 🥷 Steal window
win_swayr_steal() { swayr steal-window; }

# menu: Swayr Window Management | 🔄 Switch window
win_swayr_switch() { swayr switch-window; }

# menu: Swayr Window Management | 📑 Switch workspace
win_swayr_work() { swayr switch-workspace; }

# menu: Swayr Window Management | 📦 Move focused to workspace
win_swayr_move() { swayr move-focused-to-workspace; }


"$@"
