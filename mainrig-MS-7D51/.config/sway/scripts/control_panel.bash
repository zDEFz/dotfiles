#!/bin/bash

NON_ROOT_USER="blu"
USER_HOME="/home/$NON_ROOT_USER"

# Start dotoold if not running
if ! pgrep -x dotoold >/dev/null; then
    nohup dotoold >/dev/null 2>&1 &
fi

# Load environment variables
if [ -f "$USER_HOME/.secure_env" ]; then
    # shellcheck source=/dev/null
    . "$USER_HOME/.secure_env"
fi

# Display control functions
disable_taiko_display() {
    if pgrep -f "OpenTaiko.exe" >/dev/null; then
        pkill -f "OpenTaiko.exe"
    fi
    swaymsg output "'$TAIKO'" disable
}

enable_taiko_display() {
    swaymsg output "'$TAIKO'" enable
}

enable_support_displays() {
    for display in "$L" "$LL" "$R" "$RR"; do
        if [ -n "$display" ]; then
            swaymsg output "'$display'" enable
        fi
    done
}

# Menu entries in desired order
read -r -d '' MENU_OPTIONS << 'EOF'
--- Typing Tools ---
Type clipboard
Type date
Type vmpwd
--- Display Controls ---
Disable Taiko Display
Enable Taiko Display
Enable Support Displays
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
            printf 'key leftctrl\ntype %s\n' "$vmpwd" | dotoolc
        else
            notify-send "vmpwd variable not set"
        fi
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
        # Do nothing for section headers
        exit 0
        ;;
    *)
        notify-send "Invalid selection: $CLEAN_CHOICE"
        exit 1
        ;;
esac
