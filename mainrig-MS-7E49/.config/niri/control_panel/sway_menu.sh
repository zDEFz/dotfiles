#!/bin/bash
# sway_menu.sh - Optimized version
set -euo pipefail  # Exit on errors, undefined vars, and pipe failures

# --- CONSTANTS ---
readonly NON_ROOT_USER="blu"
readonly USER_HOME="/home/$NON_ROOT_USER"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SECURE_ENV="$USER_HOME/.secure_env"
readonly WOFI_CACHE="/dev/shm/wofi-control-panel.cache"

# EXPORT these so they are available inside the setsid bash session
export NON_ROOT_USER USER_HOME SCRIPT_DIR SECURE_ENV

# --- INITIALIZATION ---
# Load environment & start dotoold
[[ -f "$SECURE_ENV" ]] && source "$SECURE_ENV"
pgrep -x dotoold >/dev/null 2>&1 || nohup dotoold >/dev/null 2>&1 & disown

# Source all libs (consolidated loop)
shopt -s nullglob
for lib in "$SCRIPT_DIR/lib"/*.sh; do
    source "$lib"
done

# --- AUTOMATIC MENU GENERATION ---
# Single-pass menu generation with awk
MENU_CONTENT=$(
    grep -h "# menu:" "$SCRIPT_DIR/lib"/*.sh 2>/dev/null | \
    sed 's/# menu: //' | \
    sort -t'|' -k1,1 -k2,2 | \
    awk -F'|' '
        {
            gsub(/^[ \t]+|[ \t]+$/, "", $1)  # trim section
            gsub(/^[ \t]+|[ \t]+$/, "", $2)  # trim display_name
            if ($1 != prev_section) {
                print "\n--- " $1 " ---"
                prev_section = $1
            }
            print $2
        }
    ' | sed '/^$/d'
)

# Exit early if no menu content
[[ -z "$MENU_CONTENT" ]] && exit 0

# Show wofi
CHOICE=$(echo "$MENU_CONTENT" | wofi \
    --cache-file="$WOFI_CACHE" \
    --insensitive \
    --width=1000px \
    --height=800px \
    --dmenu \
    -Dlayer=overlay)

# Exit if no choice or section header selected
[[ -z "$CHOICE" || "$CHOICE" == ---* ]] && exit 0

# --- DYNAMIC DISCOVERY ---
# Combined grep for efficiency (find file and function in one pass)
mapfile -t RESULTS < <(grep -rlF "$CHOICE" "$SCRIPT_DIR/lib/" 2>/dev/null | head -n 1)

if [[ ${#RESULTS[@]} -eq 0 ]]; then
    notify-send "Error" "No matching file found for: $CHOICE"
    exit 1
fi

FILE_MATCH="${RESULTS[0]}"

# Extract function name more reliably
FUNCTION_NAME=$(grep -A 5 -F "$CHOICE" "$FILE_MATCH" 2>/dev/null | \
    grep -m 1 '()' | \
    sed -E 's/^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*).*/\1/')

if [[ -n "$FUNCTION_NAME" ]]; then
    # Execute function in background and detach
    setsid bash -c "
        # Pass exports into the new shell
        export USER_HOME='$USER_HOME'
        export NON_ROOT_USER='$NON_ROOT_USER'
        
        # Re-source environment
        [[ -f '$SECURE_ENV' ]] && source '$SECURE_ENV'
        
        # Re-source all libs in the new session so functions like _suspend exist
        shopt -s nullglob
        for lib in '$SCRIPT_DIR/lib'/*.sh; do
            source \"\$lib\"
        done
        
        # Execute the function
        $FUNCTION_NAME
    " >/dev/null 2>&1 &
else
    notify-send "Error" "No function found for: $CHOICE"
    exit 1
fi