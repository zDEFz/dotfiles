#!/bin/bash
# sway_menu.sh

NON_ROOT_USER="blu"
USER_HOME="/home/$NON_ROOT_USER"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment & dotoold
[ -f "$USER_HOME/.secure_env" ] && . "$USER_HOME/.secure_env"
pgrep -x dotoold >/dev/null || (nohup dotoold >/dev/null 2>&1 &)

# Source all libs so the functions exist in this shell
for lib in "$SCRIPT_DIR/lib"/*.sh; do . "$lib"; done

# --- AUTOMATIC MENU GENERATION ---
# Scans for: # menu: Section Name | Display Name
raw_data=$(grep -h "# menu:" "$SCRIPT_DIR/lib"/*.sh | sed 's/# menu: //')

MENU_CONTENT=""
CURRENT_SECTION=""

# Sort by Section (Column 1), then Display Name (Column 2)
while IFS='|' read -r section display_name; do
    section=$(echo "$section" | xargs)
    display_name=$(echo "$display_name" | xargs)
    
    if [[ "$section" != "$CURRENT_SECTION" ]]; then
        MENU_CONTENT+="\n--- $section ---\n"
        CURRENT_SECTION="$section"
    fi
    MENU_CONTENT+="$display_name\n"
done < <(echo "$raw_data" | sort -t'|' -k1,1 -k2,2)

# Show wofi
CHOICE=$(echo -e "$MENU_CONTENT" | sed '/^$/d' | wofi --insensitive --dmenu --cache-file=/dev/null -Dlayer=overlay)

# Exit if cancelled or if a header was clicked
[ -z "$CHOICE" ] || [[ "$CHOICE" == ---* ]] && exit 0

# --- DYNAMIC DISCOVERY ---
# Look for the file and line containing the choice, then find the function name below it
# This regex looks for the function name (e.g., "my_func()") on the line following the comment
FILE_MATCH=$(grep -rlF "$CHOICE" "$SCRIPT_DIR/lib"/)
FUNCTION_NAME=$(grep -A 1 -F "$CHOICE" "$FILE_MATCH" | grep "()" | cut -d'(' -f1 | awk '{print $NF}')

if [ -n "$FUNCTION_NAME" ]; then
    $FUNCTION_NAME
else
    notify-send "Error" "Could not find function for: $CHOICE"
fi