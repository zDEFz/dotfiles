#!/bin/bash

# Set the color variable based on user input (blue or orange)
micro_args="-colorscheme $1"
mode="$2"
workspace="$3"
name=""

# Start overall time measurement
total_start_time=$(date +%s.%N)

# Start time measurement for unique ID generation
unique_id_start_time=$(date +%s.%N)

# Generate a unique ID using the current timestamp and a random hex value (non-blocking)
unique_id=$( (timestamp=$(date +%s); 
random_hex=$(printf "%x" $((RANDOM))); 
echo "${timestamp}-${random_hex}") & wait $!)

# End time measurement for unique ID generation
unique_id_end_time=$(date +%s.%N)
unique_id_elapsed_time=$(echo "$unique_id_end_time - $unique_id_start_time" | bc)

# Output unique ID generation time
echo "Unique ID generation time: $unique_id_elapsed_time seconds"

if [[ $mode == "--startup" ]]; then
    name="alacritty-micro-startup-"
    
    # Focus output and switch workspace in a single command
    swaymsg "focus output 'BNQ ZOWIE XL LCD EBMCM01300SL0'" &
    swaymsg "workspace $workspace" &

    # Start time measurement for launching Alacritty
    alacritty_start_time=$(date +%s.%N)

    # Launch Alacritty with the unique ID as part of the class name and disown the process
    alacritty \
    --class="${name}${unique_id}" \
    -e micro $micro_args &

    # Give Alacritty time to launch
    sleep 0.3

    # Move the newly created Alacritty window to the specified position
    swaymsg "[app_id=\"${name}${unique_id}\"] move absolute position $4" &

    # End time measurement for launching Alacritty
    alacritty_end_time=$(date +%s.%N)
    alacritty_elapsed_time=$(echo "$alacritty_end_time - $alacritty_start_time" | bc)

    # Output Alacritty launch time
    echo "Alacritty launch time: $alacritty_elapsed_time seconds"
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

# End overall time measurement
total_end_time=$(date +%s.%N)
total_elapsed_time=$(echo "$total_end_time - $total_start_time" | bc)

# Output total execution time
echo "Total script execution time: $total_elapsed_time seconds"
