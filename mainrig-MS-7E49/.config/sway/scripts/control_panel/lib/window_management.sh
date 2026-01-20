#!/bin/bash

# menu: Window Management | 🎯 Focus MPV Workspace
win_focus_mpv_workspace() {
    # We search for mpvfloat instances and extract the workspace name
    local TARGET_WS=$(swaymsg -t get_tree | jq -r '.. | select(.type? == "workspace") | select(.floating_nodes? // [] | .[].app_id | test("mpvfloat")) | .name' | head -n 1)

    if [ -n "$TARGET_WS" ]; then
        swaymsg workspace "$TARGET_WS"
    else
        # Fallback to 18 if no mpvfloat is found
        swaymsg workspace 18
    fi
}

# menu: Window Management | 🎼 Realign MPV OpenMusic
win_mpv_realign() {
    local ids=$(ps aux | grep -Eo 'mpvfloat[0-9]+' | sort -u)
    local counter=0
    swaymsg workspace 18
    swaymsg "[app_id=\"^mpvfloat\d+$\"] move to workspace 18"
    while IFS= read -r id; do
        [ -z "$id" ] && continue
        local x=$((2160 + (counter % 10) * 192))
        local y=$((1679 + (counter / 10) * 108))
        swaymsg "[app_id=\"^$id$\"] move to workspace 18, move absolute position ${x}px ${y}px"
        ((counter++))
    done <<<"$ids"
}


"$@"
