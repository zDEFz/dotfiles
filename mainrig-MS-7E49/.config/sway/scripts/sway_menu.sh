#!/bin/bash
# sway_menu.sh - Main menu script for Sway utilities

NON_ROOT_USER="blu"
USER_HOME="/home/$NON_ROOT_USER"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
CONFIG_DIR="$SCRIPT_DIR/config"

# Load environment variables
if [ -f "$USER_HOME/.secure_env" ]; then
    # shellcheck source=/dev/null
    . "$USER_HOME/.secure_env"
fi

# Load video functions if available
[[ -f /home/blu/scripts/functions/in_use/media/video ]] && source /home/blu/scripts/functions/in_use/media/video

# Source all library files
for lib_file in "$LIB_DIR"/*.sh; do
    if [ -f "$lib_file" ]; then
        # shellcheck source=/dev/null
        source "$lib_file"
    fi
done

# Start dotoold
start_dotoold

# Load menu options from config file
MENU_OPTIONS=$(cat "$CONFIG_DIR/menu_options.txt")

# Show menu with history disabled to maintain order
CHOICE=$(printf '%s\n' "$MENU_OPTIONS" | wofi --insensitive --dmenu --cache-file=/dev/null --sort-order=default --hide-scroll -Dlayer=overlay)

# Exit if no choice made
[ -z "$CHOICE" ] && exit 0

# Strip non-printable characters and icons for matching
CLEAN_CHOICE=$(printf '%s' "$CHOICE" | LC_CTYPE=C sed 's/[^[:print:]]//g' | sed 's/^[[:space:]]*[^[:alnum:]]*[[:space:]]*//')

# Act based on selection
case "$CLEAN_CHOICE" in
# Typing Tools
"Type clipboard") type_clipboard ;;
"Type date") type_date ;;
"Type hostname") type_hostname ;;
"Type http+hostname") type_http_hostname ;;
"Type http+hostname+search_all") type_http_hostname_search_all ;;
"Type local ip") type_local_ip ;;
"Type vmpwd") type_vmpwd ;;
"Type veracrypt pwd") type_veracrypt_pwd ;;
"x0pipeclip") share_clipboard_text ;;

# MyAnimeList
"MAL Synopsis from clipboard") myanimelist_synopsis_clipboard ;;

# Swayr commands
"Steal window") swayr_steal_window ;;
"Switch window") swayr_switch_window ;;
"Switch workspace") swayr_switch_workspace ;;
"Move focused to workspace") swayr_move_focused_to_workspace ;;

# Move window to specific displays
"Move to L") move_focused_to_L ;;
"Move to LL") move_focused_to_LL ;;
"Move to M") move_focused_to_M ;;
"Move to MON_KB") move_focused_to_MON_KB ;;
"Move to R") move_focused_to_R ;;
"Move to RR") move_focused_to_RR ;;
"Move to TAIKO") move_focused_to_TAIKO ;;

# Display Controls - Disable
"Disable L") disable_L ;;
"Disable LL") disable_LL ;;
"Disable M") disable_M ;;
"Disable main support") disable_main_support ;;
"Disable main support and taiko") disable_main_support_and_taiko ;;
"Disable MON_KB") disable_MON_KB ;;
"Disable opt support") disable_opt_support ;;
"Disable opt support and taiko") disable_opt_support_and_taiko ;;
"Disable R") disable_R ;;
"Disable RR") disable_RR ;;
"Disable support all") disable_support_all ;;
"Disable TAIKO") disable_TAIKO ;;

# Display Controls - Enable
"Enable L") enable_L ;;
"Enable LL") enable_LL ;;
"Enable M") enable_M ;;
"Enable main support") enable_main_support ;;
"Enable main support and taiko") enable_main_support_and_taiko ;;
"Enable MON_KB") enable_MON_KB ;;
"Enable opt support") enable_opt_support ;;
"Enable opt support and taiko") enable_opt_support_and_taiko ;;
"Enable R") enable_R ;;
"Enable RR") enable_RR ;;
"Enable support all") enable_support_all ;;
"Enable TAIKO") enable_TAIKO ;;
"Enable all Seat Displays") enable_all_seat_displays ;;

# Refresh Rate
"Set refresh rate") set_refresh_rate ;;

# Application Controls
"Focus OpenTaiko") focus_opentaiko ;;
"Realign mpv Openmusic") realign_mpv_openmusic ;;
"Kill Cultris II") kill_cultris2 ;;

# System
"Follow journalctl") follow_journalctl ;;

# Section headers - do nothing
"--- Typing Tools ---" | "--- Display Controls ---" | "--- Focus Controls ---" | "--- Window Realignment ---" | "--- MyAnimeList ---" | "--- Swayr Window Management ---" | "--- Move Window to Display ---" | "--- System ---" | "--- Process Management ---")
    exit 0
    ;;

*)
    notify-send "Invalid selection: $CLEAN_CHOICE"
    exit 1
    ;;
esac
