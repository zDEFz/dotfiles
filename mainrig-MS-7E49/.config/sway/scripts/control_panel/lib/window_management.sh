#!/bin/bash

# menu: Window Management | 🎯 Focus OpenTaiko
app_opentaiko_focus() { 
    swaymsg '[class="^(OpenTaiko|opentaiko.exe)$"] focus'
}

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

# menu: Window Management | 🎼 Focus Active MPV 🎵
win_mpv_focus_active() {
local socket_dir="/dev/shm/mpvsockets"
	local playing_id=""

	# 1. Find which one is playing (using your script's logic)
	for s in "$socket_dir"/mpvfloat*; do
		playing=$(echo '{"command":["get_property","pause"]}' | socat - "$s" 2>/dev/null | jq -r '.data')
		if [[ "$playing" == "false" ]]; then
			playing_id=$(basename "$s")
			break
		fi
	done

	# 2. If found, tell sway to focus that app_id
	if [[ -n "$playing_id" ]]; then
		echo "Focusing $playing_id..."
		swaymsg "[app_id=\"$playing_id\"] focus"
		printf 'type f\n' | dotoolc
	else
		echo "No active mpv instance found."
	fi
}

# menu: Window Management | 🧲 Steal Active MPV 🎵
win_mpv_steal_active() {
    local socket_dir="/dev/shm/mpvsockets"
    local playing_id=""

    # 1. Find which one is playing (Fast check without jq for speed)
    for s in "$socket_dir"/mpvfloat*; do
        if timeout 0.03 socat - "$s" 2>/dev/null <<< '{"command":["get_property","pause"]}' | grep -q '"data":false'; then
            playing_id=$(basename "$s")
            break
        fi
    done

    # 2. If found, "steal" it to the current workspace and focus
    if [[ -n "$playing_id" ]]; then
        echo "Stealing $playing_id to current workspace..."
        # Move the window to the current workspace and focus it
        swaymsg "[app_id=\"$playing_id\"] move container to workspace current, focus"		
		swaymsg "[app_id=\"$playing_id\"] layout hsplit"

    else
        echo "No active mpv instance found."
    fi
}

# menu: Window Management | 🧲 Steal Active MPV and defloat 🎵
win_mpv_steal_active_defloat() {
    local socket_dir="/dev/shm/mpvsockets"
    local playing_id=""

    # 1. Find which one is playing (Fast check without jq for speed)
    for s in "$socket_dir"/mpvfloat*; do
        if timeout 0.03 socat - "$s" 2>/dev/null <<< '{"command":["get_property","pause"]}' | grep -q '"data":false'; then
            playing_id=$(basename "$s")
            break
        fi
    done

    # 2. If found, "steal" it to the current workspace and focus
    if [[ -n "$playing_id" ]]; then
        echo "Stealing $playing_id to current workspace..."
        # Move the window to the current workspace and focus it
        swaymsg "[app_id=\"$playing_id\"] move container to workspace current, focus"		
		swaymsg "[app_id=\"$playing_id\"] floating disable"
		swaymsg "[app_id=\"$playing_id\"] layout hsplit"

    else
        echo "No active mpv instance found."
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
