#!/bin/bash

NON_ROOT_USER="blu"
USER_HOME="/home/$NON_ROOT_USER"

# Start dotoold if not running
if ! pgrep -x dotoold >/dev/null; then
    nohup dotoold >/dev/null 2>&1 &
fi

[[ -f /home/blu/scripts/functions/in_use/media/video ]] && source /home/blu/scripts/functions/in_use/media/video

# Load environment variables
if [ -f "$USER_HOME/.secure_env" ]; then
    # shellcheck source=/dev/null
    . "$USER_HOME/.secure_env"
fi

myanimelist_synopsis_clipboard() { 
	$USER_HOME/.config/sway/scripts/myanimelist_coverart_search.sh "$(wl-paste)"
}

share_clipboard_text() {
    source /home/blu/scripts/functions/in_use/transfers/paste_services
    0x0pipeclip "$(wl-paste)"
}

enable_all_seat_displays(){ 
	for display in "$L" "$LL" "$M" "$MON_KB" "$R" "$RR" ; do 
		if [ -n "$display" ]; then
		   swaymsg output "'$display'" enable
		fi
	done
}

focus_opentaiko () {
	swaymsg '[class="^(OpenTaiko|opentaiko.exe)$"] focus'
}

realign_mpv_openmusic () {
	base_x=2160 
	base_y=1679 
	x_step=192 
	y_step=108 
	per_row=10 
	ids=$(ps aux \
	    | grep -Eo 'mpvfloat[0-9]+' \
	    | sort -u) 
	total=$(printf "%s\n" "$ids" | wc -l) 
	counter=0 
	swaymsg workspace 18
	swaymsg "[app_id=\"^mpvfloat\d+$\"] move to workspace 18" > /dev/null 2>&1
	while IFS= read -r id
	do
		row=$(( counter / per_row )) 
		col=$(( counter % per_row )) 
		x=$(( base_x + col * x_step )) 
		y=$(( base_y + row * y_step )) 
		swaymsg "[app_id=\"^$id$\"] move to workspace 18, move absolute position ${x}px ${y}px" > /dev/null 2>&1
		((counter++))
	done <<< "$ids"
	echo "Re-aligned $total mpv windows onto workspace 18."
}

# Swayr functions
swayr_steal_window() {
    swayr steal-window
}

swayr_switch_window() {
    swayr switch-window
}

swayr_switch_workspace() {
    swayr switch-workspace
}

swayr_move_focused_to_workspace() {
    swayr move-focused-to-workspace
}

# Move focused window to specific displays
move_focused_to_L() {
    if [ -n "$L" ]; then
        swaymsg move container to output "'$L'"
    else
        notify-send "L display not defined"
    fi
}

move_focused_to_LL() {
    if [ -n "$LL" ]; then
        swaymsg move container to output "'$LL'"
    else
        notify-send "LL display not defined"
    fi
}

move_focused_to_M() {
    if [ -n "$M" ]; then
        swaymsg move container to output "'$M'"
    else
        notify-send "M display not defined"
    fi
}

move_focused_to_MON_KB() {
    if [ -n "$MON_KB" ]; then
        swaymsg move container to output "'$MON_KB'"
    else
        notify-send "MON_KB display not defined"
    fi
}

move_focused_to_R() {
    if [ -n "$R" ]; then
        swaymsg move container to output "'$R'"
    else
        notify-send "R display not defined"
    fi
}

move_focused_to_RR() {
    if [ -n "$RR" ]; then
        swaymsg move container to output "'$RR'"
    else
        notify-send "RR display not defined"
    fi
}

move_focused_to_TAIKO() {
    if [ -n "$TAIKO" ]; then
        swaymsg move container to output "'$TAIKO'"
    else
        notify-send "TAIKO display not defined"
    fi
}

# Menu entries in desired order with icons
read -r -d '' MENU_OPTIONS << 'EOF'
--- Typing Tools ---
Type clipboard
📅 Type date
🔐 Type vmpwd
🔗 0x0pipeclip
--- MyAnimeList ---
MAL Synopsis from clipboard
--- Swayr Window Management ---
Steal window
Switch window
Switch workspace
Move focused to workspace
--- Move Window to Display ---
Move to L
Move to LL
Move to M
Move to MON_KB
Move to R
Move to RR
🥁 Move to TAIKO
--- Display Controls ---
❌ Disable L
❌ Disable LL
❌ Disable M
❌ Disable main support
❌ Disable main support and taiko
❌ Disable MON_KB
❌ Disable opt support
❌ Disable opt support and taiko
❌ Disable R
❌ Disable RR
❌ Disable support all
❌ Disable TAIKO
✅ Enable L
✅ Enable LL
✅ Enable M
✅ Enable main support
✅ Enable main support and taiko
✅ Enable MON_KB
✅ Enable opt support
✅ Enable opt support and taiko
✅ Enable R
✅ Enable RR
✅ Enable support all
✅ Enable TAIKO
Enable all Seat Displays
--- Focus Controls ---
🥁 Focus OpenTaiko
--- Window Realignment ---
Realign mpv Openmusic
EOF

# Show menu with history disabled to maintain order
CHOICE=$(printf '%s\n' "$MENU_OPTIONS" | wofi --insensitive --dmenu --cache-file=/dev/null --sort-order=default --hide-scroll -Dlayer=overlay)

# Exit if no choice made
[ -z "$CHOICE" ] && exit 0

# Strip non-printable characters and icons for matching
CLEAN_CHOICE=$(printf '%s' "$CHOICE" | LC_CTYPE=C sed 's/[^[:print:]]//g' | sed 's/^[[:space:]]*[^[:alnum:]]*[[:space:]]*//')

# Act based on selection
case "$CLEAN_CHOICE" in
    "Type clipboard")
        TEXT=$(wl-paste)
        if [ -n "$TEXT" ]; then
            printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
        else
            notify-send "Clipboard is empty"
        fi
        ;;
    "Type date")
        TEXT=$(date --iso-8601)
        printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
        ;;
    "Type vmpwd")
        if [ -n "$vmpwd" ]; then
            printf 'key leftctrl\ntype %s\nkey Tab\nkey space\nkey Tab\nkey space\n' "$vmpwd" | dotoolc
        else
            notify-send "vmpwd variable not set"
        fi
        ;;
    "0x0pipeclip")
        share_clipboard_text
        ;;
    "MAL Synopsis from clipboard")
        myanimelist_synopsis_clipboard
        ;;
    # Swayr commands
    "Steal window")
        swayr_steal_window
        ;;
    "Switch window")
        swayr_switch_window
        ;;
    "Switch workspace")
        swayr_switch_workspace
        ;;
    "Move focused to workspace")
        swayr_move_focused_to_workspace
        ;;
    # Move window to specific displays
    "Move to L")
        move_focused_to_L
        ;;
    "Move to LL")
        move_focused_to_LL
        ;;
    "Move to M")
        move_focused_to_M
        ;;
    "Move to MON_KB")
        move_focused_to_MON_KB
        ;;
    "Move to R")
        move_focused_to_R
        ;;
    "Move to RR")
        move_focused_to_RR
        ;;
    "Move to TAIKO")
        move_focused_to_TAIKO
        ;;
    "Disable L")
        disable_L
        ;;
    "Disable LL")
        disable_LL
        ;;
    "Disable M")
        disable_M
        ;;
    "Disable main support")
        disable_main_support
        ;;
    "Disable main support and taiko")
        disable_main_support_and_taiko
        ;;
    "Disable MON_KB")
        disable_MON_KB
        ;;
    "Disable opt support")
        disable_opt_support
        ;;
    "Disable opt support and taiko")
        disable_opt_support_and_taiko
        ;;
    "Disable R")
        disable_R
        ;;
    "Disable RR")
        disable_RR
        ;;
    "Disable support all")
        disable_support_all
        ;;
    "Disable TAIKO")        
        disable_TAIKO
        ;;
    "Enable L")
        enable_L
        ;;
    "Enable LL")
        enable_LL
        ;;
    "Enable M")
        enable_M
        ;;
    "Enable main support")
        enable_main_support
        ;;
    "Enable main support and taiko")
        enable_main_support_and_taiko
        ;;
    "Enable MON_KB")
        enable_MON_KB
        ;;
    "Enable opt support")
        enable_opt_support
        ;;
    "Enable opt support and taiko")
        enable_opt_support_and_taiko
        ;;
    "Enable R")
        enable_R
        ;;
    "Enable RR")
        enable_RR
        ;;
    "Enable support all")
        enable_support_all
        ;;
    "Enable TAIKO")
        enable_TAIKO
        ;;
    "Enable all Seat Displays")
        enable_all_seat_displays
        ;;
    "Focus OpenTaiko")
        focus_opentaiko
        ;;
    "Realign mpv Openmusic")        
        realign_mpv_openmusic
        ;;
    "--- Typing Tools ---" | "--- Display Controls ---" | "--- Focus Controls ---" | "--- Window Realignment ---" | "--- MyAnimeList ---" | "--- Swayr Window Management ---" | "--- Move Window to Display ---")
        # Do nothing for section headers
        exit 0
        ;;
    *)
        notify-send "Invalid selection: $CLEAN_CHOICE"
        exit 1
        ;;
esac
