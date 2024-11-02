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

# Start overall time measurement
total_start_time=$(date +%s.%N)

# Check for mode and set name and class based on it
if [[ $mode == "--startup" ]]; then
    name="alacritty-micro-startup-"
    
    # Focus output and switch workspace in a single command
    swaymsg "focus output 'BNQ ZOWIE XL LCD EBMCM01300SL0'" &
    swaymsg "workspace $workspace" &

    # Start time measurement for launching Alacritty
    alacritty_start_time=$(date +%s.%N)

    # Generate the fixed unique ID based on the filename
    unique_id=$(generate_fixed_id "$1")
    
    # Launch Alacritty with the fixed unique ID as part of the class name and disown the process
    alacritty \
    --class="${name}${unique_id}" \
    -e micro $micro_args &
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

    sleep .1
    swaymsg "for_window [class="${name}${unique_id}"] floating enable"


    # End time measurement for launching Alacritty in cursor mode
    cursor_end_time=$(date +%s.%N)
    cursor_elapsed_time=$(echo "$cursor_end_time - $cursor_start_time" | bc)

    # Output cursor mode launch time
    echo "Cursor mode Alacritty launch time: $cursor_elapsed_time seconds"
fi

# End overall time measurement
total_end_time=$(date +%s.%N)
total_elapsed_time=$(echo "$total_end_time - $total_start_time" | bc)

# Output total execution time
echo "Total script execution time: $total_elapsed_time seconds"
