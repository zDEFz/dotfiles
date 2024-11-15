#!/bin/bash

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
    # You can modify the filename here if needed (e.g., remove spaces, etc.)
    echo "${filename// /_}"  # Replace spaces with underscores (optional)
}

# Check for mode and set name and class based on it
if [[ $mode == "--startup" ]]; then
    name="alacritty-micro-startup-"
    
    # Focus output and switch workspace in a single command
    swaymsg "focus output 'BNQ ZOWIE XL LCD EBMCM01300SL0'" &

    if [[ ! $workspace -eq "" ]]; then 
        swaymsg "workspace $workspace" &
    else
        echo "Assuming set by sway config. $micro_args "
    fi

    # Start time measurement for launching Alacritty
    alacritty_start_time=$(date +%s.%N)

    # Generate the fixed unique ID based on the filename
    fixed_id=$(generate_fixed_id "$1")

    # Check if any app_id starting with 'alacritty-micro-startup-' matches the generated fixed_id
    if ! swaymsg -t get_tree | jq -r '.. | .app_id? // empty' | grep -q "^alacritty-micro-startup-${fixed_id}$"; then
        # Launch Alacritty with the fixed unique ID as part of the class name and disown the process
        alacritty --class="${name}${fixed_id}" -e micro $micro_args &
    else
        echo "'$fixed_id' already runs. Not launching."
    fi

fi

if [[ $mode == "--cursor" ]]; then
    name="alacritty-micro-cursor-"
    
    # Start time measurement for launching Alacritty in cursor mode
    cursor_start_time=$(date +%s.%N)
    
    p="/home/blu/notes/custom/"

    alacritty \
    --working-directory=${p} \
    --class="${name}${unique_id}" \
    -e micro $micro_args &

    # End time measurement for launching Alacritty in cursor mode
    cursor_end_time=$(date +%s.%N)
    cursor_elapsed_time=$(echo "$cursor_end_time - $cursor_start_time" | bc)

    # Output cursor mode launch time
    echo "Cursor mode Alacritty launch time: $cursor_elapsed_time seconds"
fi