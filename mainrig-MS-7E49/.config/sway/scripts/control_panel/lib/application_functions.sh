# application_functions.sh
kill_cultris2() {
    pkill -9 -f cultris2.jar && notify-send "Cultris II" "Terminated" || notify-send "Cultris II" "Not running"
}

focus_opentaiko() { swaymsg '[class="^(OpenTaiko|opentaiko.exe)$"] focus'; }

follow_journalctl() {
    alacritty --config-file="$USER_HOME/.config/alacritty/alacritty_non_opaque.toml" \
              --class alacritty_floating --title "Floating Terminal" -e bash -c "sudo journalctl -f"
}

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

# dotoold_manager.sh
start_dotoold() {
    pgrep -x dotoold >/dev/null || (nohup dotoold >/dev/null 2>&1 & echo "dotoold started")
}