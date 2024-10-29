#!/bin/bash
source ~/.config/i3/mutelist.conf

declare -A entry_map
declare entries

prev_matched=""
prev_stopped=""
process_stopped=false

while true; do 
    cur=$(/home/blu/.config/i3blocks/i3blocks/custom/i3-focusedwindow -class)

    # Check if the current window class name is different from the previous matched one
    if [[ $cur != $prev_matched ]]; then
        echo "Previous matched window class: $prev_matched"
        echo "Current window class: $cur"
        if [[ -n $prev_matched ]]; then
            if ! $process_stopped; then
                echo "Stopping previous process..."
                kill -STOP "$(pidof "$prev_matched")"
                prev_stopped="$prev_matched"
                process_stopped=true
            fi
        fi
    fi

    # Check if the current window class is the same as the previously stopped one
    if [[ $cur == $prev_stopped ]]; then
        echo "Resuming previously stopped process..."
        kill -CONT "$(pidof "$cur")"
        prev_stopped=""
        process_stopped=false
    fi

    # Populate entry_map from entries array
    for entry in "${entries[@]}"; do
        IFS=',' read -ra parts <<< "$entry"
        entry_map[${parts[0]}]=${parts[1]}
    done

    # Loop through entry_map to match window class name with regex
    for entry in "${!entry_map[@]}"; do
        regex="${entry_map[$entry]}"
        if [[ "$cur" =~ $regex ]]; then
            # Check if the current window class was not matched in the previous iteration
            if [[ $cur != $prev_matched ]]; then
                echo "Match found for $entry: $cur"
                # If the previously stopped process is now in focus, resume it
                if [[ $cur == $prev_stopped ]]; then
                    echo "Resuming previously stopped process..."
                    kill -CONT "$(pidof "$cur")"
                    prev_stopped=""
                    process_stopped=false
                fi
            fi
            prev_matched=$cur  # Update the previous matched window class name
            search_term="$entry"
            break
        fi
    done

    sleep 1  # Adjust sleep duration as needed
done
