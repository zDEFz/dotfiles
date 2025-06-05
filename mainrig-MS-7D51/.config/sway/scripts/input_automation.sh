#!/bin/bash

NON_ROOT_USER="blu"
USER_HOME="/home/$NON_ROOT_USER"

# Start dotoold if not running
! pgrep -x dotoold >/dev/null && nohup dotoold >/dev/null 2>&1 &

# Load environment variables
[ -f "$USER_HOME/.secure_env" ] && . "$USER_HOME/.secure_env"

# Define display control functions
disable_taiko_display () {
    killall "OpenTaiko.exe"
    swaymsg 'output "BNQ ZOWIE XL LCD EBX7M01214SL0" disable'
}

enable_taiko_display () {
    swaymsg 'input 1003:8258:Keyboard' events enabled
    swaymsg 'output "BNQ ZOWIE XL LCD EBX7M01214SL0" enable'
}

enable_support_displays () {
    for display in {$L,$LL,$R,$RR}; do
        swaymsg output "'$display'" enable
    done
}

# Menu options in correct order, no prefixes needed
MENU_OPTIONS="\
--- Typing Tools ---\n\
Type clipboard\n\
Type date\n\
Type vmpwd\n\
--- Display Controls ---\n\
Disable Taiko Display\n\
Enable Taiko Display\n\
Enable Support Displays"

# Show wofi menu with preserved order
CHOICE=$(echo -e "$MENU_OPTIONS" | wofi --dmenu --sort-order=default --hide-scroll -Dlayer=overlay)
[ "$CHOICE" ] || exit

# Remove non-printables just in case
CLEAN_CHOICE=$(echo "$CHOICE" | LC_CTYPE=C sed 's/[^[:print:]]//g')

# Handle selection
case "$CLEAN_CHOICE" in
    "Type clipboard")
        TEXT=$(wl-paste)
        echo -e "key leftctrl\ntype $TEXT" | dotoolc
        ;;
    "Type date")
        TEXT=$(date --iso-8601)
        echo -e "key leftctrl\ntype $TEXT" | dotoolc
        ;;
    "Type vmpwd")
        TEXT=${vmpwd}
        echo -e "key leftctrl\ntype $TEXT" | dotoolc
        ;;
    "Disable Taiko Display")
        disable_taiko_display
        ;;
    "Enable Taiko Display")
        enable_taiko_display
        ;;
    "Enable Support Displays")
        enable_support_displays
        ;;
    "--- Typing Tools ---" | "--- Display Controls ---")
        exit 0
        ;;
    *)
        notify-send "No valid selection"
        exit 1
        ;;
esac
