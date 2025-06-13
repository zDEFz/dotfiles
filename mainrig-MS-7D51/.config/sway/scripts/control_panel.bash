#!/bin/bash
NON_ROOT_USER="blu"
USER_HOME="/home/$NON_ROOT_USER"

# Start dotoold if not running
if ! pgrep -x dotoold >/dev/null; then
    nohup dotoold >/dev/null 2>&1 &
fi

[[ -f /home/blu/scripts/functions/displays ]] && source /home/blu/scripts/functions/displays

# Load environment variables
if [ -f "$USER_HOME/.secure_env" ]; then
    # shellcheck source=/dev/null
    . "$USER_HOME/.secure_env"
fi

enable_all_seat_displays(){ 
	for display in "$L" "$LL" "$M" "$MON_KB" "$R" "$RR" ; do 
		if [ -n "$display" ]; then
		            swaymsg output "'$display'" enable
		fi
	done
}

focus_opentaiko () {
	swaymsg '[class="^opentaiko.exe$"] focus'
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

# Menu entries in desired order
read -r -d '' MENU_OPTIONS << 'EOF'
--- Typing Tools ---
Type clipboard
Type date
Type vmpwd
--- Display Controls ---
Disable Main Support Displays And Taiko Screen
Disable MON_KB
Disable Opt Support Displays
Disable Support Displays
Disable Taiko Display
Enable all Seat Displays
Enable MON_KB
Enable Opt Support Displays
Enable Support Displays
Enable Taiko Display
--- Focus Controls ---
Focus OpenTaiko
--- Window Realignment ---
Realign mpv Openmusic
EOF

# Show menu with history disabled to maintain order
CHOICE=$(printf '%s\n' "$MENU_OPTIONS" | wofi --insensitive --dmenu --cache-file=/dev/null --sort-order=default --hide-scroll -Dlayer=overlay)

# Exit if no choice made
[ -z "$CHOICE" ] && exit 0

# Strip non-printable characters (for safety)
CLEAN_CHOICE=$(printf '%s' "$CHOICE" | LC_CTYPE=C sed 's/[^[:print:]]//g')

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
    "Enable all Seat Displays")
        enable_all_seat_displays
        ;;    
    "Disable Taiko Display")
        disable_TAIKO
        ;;
    "Enable Taiko Display")
        enable_TAIKO
        ;;
    "Enable Support Displays")
        enable_support_all
        ;;
    "Disable Support Displays")
        enable_support_all
        ;;
    "Enable Opt Support Displays")
        enable_opt_support
        ;;
    "Disable Opt Support Displays")
        disable_opt_support
        ;;
    "Disable Main Support Displays And Taiko Screen")
        disable_opt_support_and_taiko
        ;;
    "Enable MON_KB")
        enable_MON_KB
        ;;
    "Disable MON_KB")
        disable_MON_KB
        ;;
    "Focus OpenTaiko")
        focus_opentaiko
        ;;
    "Realign mpv Openmusic")        
        realign_mpv_openmusic
        ;;
    "--- Typing Tools ---" | "--- Display Controls ---")
        # Do nothing for section headers
        exit 0
        ;;
    *)
        notify-send "Invalid selection: $CLEAN_CHOICE"
        exit 1
        ;;
esac
