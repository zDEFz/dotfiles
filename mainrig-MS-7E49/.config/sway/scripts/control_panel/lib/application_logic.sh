#!/bin/bash

# menu: Focus Controls | 🥁 Focus OpenTaiko
f_taiko() { swaymsg '[class="^(OpenTaiko|opentaiko.exe)$"] focus'; }

# menu: Window Realignment | Realign mpv Openmusic
realign_mpv() {
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

# menu: System | 🧾 Follow journalctl
f_journal() {
    alacritty --config-file="$USER_HOME/.config/alacritty/alacritty_non_opaque.toml" \
              --class alacritty_floating --title "Floating Terminal" -e bash -c "sudo journalctl -f"
}

# menu: Process Management | Kill Cultris II
k_cultris() { pkill -9 -f cultris2.jar && notify-send "Cultris II" "Terminated" || notify-send "Cultris II" "Not running"; }