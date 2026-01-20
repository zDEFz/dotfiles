#!/bin/bash

# --- CATEGORY: HELPERS ---
# Internal helper used for moving containers to specific outputs
_win_move_to_output() { 
    swaymsg move container to output "'${!1}'"
}

