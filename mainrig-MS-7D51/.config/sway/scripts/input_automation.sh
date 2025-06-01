#!/bin/bash
NON_ROOT_USER="blu"
USER_HOME="/home/$NON_ROOT_USER"
MENU_OPTIONS="Type clipboard\nType vmpwd\nType date"
# Start dotoold if not running
! pgrep -x dotoold >/dev/null && nohup dotoold >/dev/null 2>&1 &
# Load environment variables
[ -f "$USER_HOME/.secure_env" ] && . "$USER_HOME/.secure_env"
# Get user selection
CHOICE=$(echo -e "$MENU_OPTIONS" | wofi --dmenu --hide-scroll -Dlayer=overlay)
[ "$CHOICE" ] || exit
# Set text based on choice
case "$CHOICE" in
    "Type clipboard") TEXT=$(wl-paste) ;;
    "Type vmpwd") TEXT=${vmpwd} ;;
    "Type date") TEXT=$(date --iso-8601) ;;
    *) notify-send "No valid selection"; exit ;;
esac
# Type the text
{ echo "key leftctrl"; echo "type $TEXT"; } | dotoolc
