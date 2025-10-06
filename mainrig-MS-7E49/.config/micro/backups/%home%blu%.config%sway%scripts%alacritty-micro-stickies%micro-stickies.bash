#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Log file for error suppression
log_file="/tmp/alacritty_micro_manager.log"

# Set the color variable based on user input (blue or orange)
micro_args="-colorscheme $1"
mode="$2"
workspace="$3"
position="$4"
name=""

# Function to generate a fixed unique ID from the filename
generate_fixed_id() {
    local fullpath="$1"
    local filename=$(basename "$fullpath")
    echo "${filename// /_}"  # Replace spaces with underscores
}

# Function to measure and log execution time
measure_time() {
    local start_time=$1
    local end_time=$(date +%s.%N)
    local elapsed_time=$(echo "$end_time - $start_time" | bc)
    echo -e "${CYAN}${BOLD}[INFO]${RESET} $2: $elapsed_time seconds"
}

# Handle startup mode
if [[ $mode == "--startup" ]]; then
    name="alacritty-micro-startup-"

    echo -e "${CYAN}${BOLD}[INFO]${RESET} Focusing output and switching workspace..."
    swaymsg "focus output 'BNQ ZOWIE XL LCD EBMCM01300SL0'" &

    if [[ -n "$workspace" ]]; then
        echo -e "${CYAN}${BOLD}[INFO]${RESET} Switching to workspace $workspace"
        swaymsg "workspace $workspace" &
    else
        echo -e "${YELLOW}${BOLD}[WARNING]${RESET} No workspace provided. Assuming set by sway config."
    fi

    # Measure startup time
    start_time=$(date +%s.%N)

    # Generate unique ID and check if already running
    fixed_id=$(generate_fixed_id "$1")
    if ! swaymsg -t get_tree | jq -r '.. | .app_id? // empty' | grep -q "^alacritty-micro-startup-${fixed_id}$"; then
        echo -e "${GREEN}${BOLD}[LAUNCHING]${RESET} Launching Alacritty with profile: $fixed_id"
        alacritty --class="${name}${fixed_id}" -e micro $micro_args 2>> "$log_file" &
    else
        echo -e "${CYAN}${BOLD}[INFO]${RESET} '$fixed_id' is already running. Not launching."
    fi

    # Log elapsed time
    measure_time "$start_time" "Alacritty startup time"
fi

# Handle cursor mode
if [[ $mode == "--cursor" ]]; then
    name="alacritty-micro-cursor-"
    start_time=$(date +%s.%N)

    echo -e "${CYAN}${BOLD}[INFO]${RESET} Launching Alacritty in cursor mode..."
    # pre-determine position so we only match it once foreach instance
    swaymsg 'for_window [app_id="^alacritty-micro-cursor-*$"] move to position cursor'
    
    alacritty \
        --working-directory="/home/blu/notes/custom/" \
        --class="${name}${unique_id}" \
        -e micro $micro_args 2>> "$log_file" &
    
    
    # Log elapsed time
    measure_time "$start_time" "Cursor mode Alacritty launch time"
fi

# End Message
echo -e "${CYAN}${BOLD}============================== Script Finished ==============================${RESET}"
