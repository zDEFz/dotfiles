#!/bin/bash

# Initialize last_window and last_value to ensure the first check works correctly
last_window=""
last_value=""

while true; do
    # Dynamically get the current active window name
    cur="$(xdotool getactivewindow getwindowname)"
    
    # Check if the window is "Cultris II" and set the new_value accordingly
    if [ "$cur" == "Cultris II" ]; then
        new_value=240
    else
        new_value=1
    fi

    # Only write to the file if the window name or value has changed
    if [ "$cur" != "$last_window" ] || [ "$new_value" != "$last_value" ]; then
        echo $new_value >| ~/c2/c2-patch/settings/FE-fpsvalue.txt
        # Update last_window and last_value to the current ones
        last_window="$cur"
        last_value="$new_value"
    fi

    # Pause for 0.5 seconds before checking again
    sleep 0.5
done
