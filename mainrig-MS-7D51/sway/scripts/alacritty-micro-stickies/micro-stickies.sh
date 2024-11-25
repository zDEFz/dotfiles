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

# Function to generate a fixed unique ID from the filename only
generate_fixed_id() {
    local fullpath="$1"
    local filename=$(basename "$fullpath")  # Extract the filename from the path only
    # Replace spaces with underscores (optional)
    echo "${filename// /_}"  
}

# Check for mode and set name and class based on it
if [[ $mode == "--startup" ]]; then
    name="alacritty-micro-startup-"
    
    # Focus output and switch workspace in a single command
    echo -e "${CYAN}${BOLD}[INFO]${RESET} Focusing output and switching workspace..."
    swaymsg "focus output 'BNQ ZOWIE XL LCD EBMCM01300SL0'" &

    if [[ ! -z "$workspace" ]]; then
        echo -e "${CYAN}${BOLD}[INFO]${RESET} Switching to workspace $workspace"
        swaymsg "workspace $workspace" &
    else
        echo -e "${YELLOW}${BOLD}[WARNING]${RESET} No workspace provided. Assuming set by sway config."
    fi

    # Start time measurement for launching Alacritty
    alacritty_start_time=$(date +%s.%N)

    # Generate the fixed unique ID based on the filename
    fixed_id=$(generate_fixed_id "$1")

    # Check if any app_id starting with 'alacritty-micro-startup-' matches the generated fixed_id
    if ! swaymsg -t get_tree | jq -r '.. | .app_id? // empty' | grep -q "^alacritty-micro-startup-${fixed_id}$"; then
        echo -e "${GREEN}${BOLD}[LAUNCHING]${RESET} Launching Alacritty with profile: $fixed_id"
        # Launch Alacritty with the fixed unique ID as part of the class name and disown the process
        alacritty --class="${name}${fixed_id}" -e micro $micro_args 2>> "$log_file" &
    else
        echo -e "${CYAN}${BOLD}[INFO]${RESET} '$fixed_id' is already running. Not launching."
    fi

    # End time measurement for startup
    alacritty_end_time=$(date +%s.%N)
    alacritty_elapsed_time=$(echo "$alacritty_end_time - $alacritty_start_time" | bc)
    echo -e "${CYAN}${BOLD}[INFO]${RESET} Alacritty startup time: $alacritty_elapsed_time seconds"

fi

if [[ $mode == "--cursor" ]]; then
    name="alacritty-micro-cursor-"
    
    # Start time measurement for launching Alacritty in cursor mode
    cursor_start_time=$(date +%s.%N)
    
    p="/home/blu/notes/custom/"

    echo -e "${CYAN}${BOLD}[INFO]${RESET} Launching Alacritty in cursor mode..."
    alacritty \
    --working-directory=${p} \
    --class="${name}${unique_id}" \
    -e micro $micro_args 2>> "$log_file" &

    # End time measurement for cursor mode
    cursor_end_time=$(date +%s.%N)
    cursor_elapsed_time=$(echo "$cursor_end_time - $cursor_start_time" | bc)

    # Output cursor mode launch time
    echo -e "${CYAN}${BOLD}[INFO]${RESET} Cursor mode Alacritty launch time: $cursor_elapsed_time seconds"
fi

# End Message
echo -e "${CYAN}${BOLD}============================== Script Finished ==============================${RESET}"
