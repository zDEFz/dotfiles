#!/bin/bash

# menu: Move Window to Display | Move to L
move_focused_to_L() { swaymsg move container to output "'$L'"; }
# menu: Move Window to Display | Move to LL
move_focused_to_LL() { swaymsg move container to output "'$LL'"; }
# menu: Move Window to Display | Move to M
move_focused_to_M() { swaymsg move container to output "'$M'"; }
# menu: Move Window to Display | Move to MON_KB
move_focused_to_MON_KB() { swaymsg move container to output "'$MON_KB'"; }
# menu: Move Window to Display | Move to R
move_focused_to_R() { swaymsg move container to output "'$R'"; }
# menu: Move Window to Display | Move to RR
move_focused_to_RR() { swaymsg move container to output "'$RR'"; }
# menu: Move Window to Display | 🥁 Move to TAIKO
move_focused_to_TAIKO() { swaymsg move container to output "'$TAIKO'"; }

# menu: Swayr Window Management | Steal window
swayr_steal_window() { swayr steal-window; }
# menu: Swayr Window Management | Switch window
swayr_switch_window() { swayr switch-window; }
# menu: Swayr Window Management | Switch workspace
swayr_switch_workspace() { swayr switch-workspace; }
# menu: Swayr Window Management | Move focused to workspace
swayr_move_focused_to_workspace() { swayr move-focused-to-workspace; }

# menu: Focus Controls | 🥁 Focus OpenTaiko
focus_opentaiko() { swaymsg '[class="^(OpenTaiko|opentaiko.exe)$"] focus'; }

# menu: Process Management | Kill Cultris II
kill_cultris2() { pkill -9 -f cultris2.jar && notify-send "Cultris II" "Terminated" || notify-send "Cultris II" "Not running"; }

# menu: System | 🧾 Follow journalctl
follow_journalctl() {
    alacritty --config-file="$USER_HOME/.config/alacritty/alacritty_non_opaque.toml" \
              --class alacritty_floating --title "Floating Terminal" -e bash -c "sudo journalctl -f"
}

# menu: Window Realignment | Realign mpv Openmusic
realign_mpv_openmusic() {
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