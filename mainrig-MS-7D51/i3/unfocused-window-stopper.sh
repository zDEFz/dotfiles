#!/bin/bash

### STOP all windows that match criteria

source ~/.config/i3/mutelist.conf

prev_matched=""
process_stopped=false

# Enable extended pattern matching
shopt -s extglob

# Get a list of open windows using wmctrl
open_windows=$(i3-msg -t get_tree | jq -r '.. | .window_properties? | select(.class) | .class'
)

# Initialize an array to store matching window IDs
matching_results=()

# Loop through each entry
for entry in "${entries[@]}"; do
    regex="${entry%%,*}"  # Extract the regex part before the comma
    target="${entry#*,}"  # Extract the target part after the comma
    echo "Searching for windows matching regex: $regex"

    # Perform regex search on open windows
    for window_title in $open_windows; do
        if [[ $window_title =~ $regex ]]; then
            echo "Window title: $window_title"
            echo "Regex pattern: $regex"
            echo STOP $window_title
            kill -STOP $(pidof $window_title)
        fi
    done
done

# Print the array of matching search results
echo "Matching search results: ${matching_results[@]}"


### STOP and CONT all windows that match criteria always.

while true; do 
    cur=$(xdotool getactivewindow getwindowclassname)

    if [[ $cur != $prev_matched ]]; then
        echo "Previous matched window class: $prev_matched"
        echo "Current window class: $cur"
        if [[ -n $prev_matched ]]; then
            if ! $process_stopped; then
                echo "Stopping previous process..."
                if pkill -STOP "$prev_matched"; then
                    echo "Process stopped successfully."
                    process_stopped=true
                else
                    echo "Failed to stop process."
                fi
            fi
        fi
    fi

    if [[ $cur == $prev_matched ]]; then
        echo "Resuming previously stopped process..."
        if pkill -CONT "$cur"; then
            echo "Process resumed successfully."
            process_stopped=false
        else
            echo "Failed to resume process."
        fi
    fi

    for entry in "${entries[@]}"; do
        IFS=',' read -ra parts <<< "$entry"
        regex="${parts[1]}"
        if [[ "$cur" =~ $regex ]]; then
            if [[ $cur != $prev_matched ]]; then
                echo "Match found for ${parts[0]}: $cur"
            fi
            prev_matched=$cur
            break
        fi
    done

    sleep .3
done
