#!/bin/bash

# Start timer
start_time=$(date +%s%3N)  # Current time in milliseconds

b="$HOME/mpvsock-bg-"

MPV_L_WALL_PATH="/home/blu/.config/sway/wallpaper/L_SCREEN/"
MPV_R_WALL_PATH="/home/blu/.config/sway/wallpaper/R_SCREEN/"
MPV_SOCK_L="${b}left"
MPV_SOCK_R="${b}right"

# Start mpvpaper instances for left and right monitors
mpvpaper -f -o "input-ipc-server=$MPV_SOCK_L --no-keepaspect-window" -n 10 'DP-2' null &
mpvpaper -f -o "input-ipc-server=$MPV_SOCK_R --no-keepaspect-window" -n 10 'DP-1' null &

# Allow some time for mpvpaper to start (can be reduced)
sleep 0.2

# Cache visible workspaces
get_visible_workspaces() {
    swaymsg -t get_workspaces | jq -r '.[] | select(.visible == true) | .num'
}

# Set wallpapers based on workspace number
set_wallpaper() {
    case "$1" in
        1) echo "${MPV_L_WALL_PATH}22BW73_resized.png" ;;
        2) echo "${MPV_R_WALL_PATH}4K - _vectorpaper__tatsumaki_by_azizkeybackspace-d9gq3v7(noise_scale)(x2.0)(level1).png" ;;
        3) echo "${MPV_L_WALL_PATH}002e1ab4d079c20f36dbefdf83aa73ee_001(noise_scale)(x2.0)(level1)_cr.png" ;;
        *) return ;;
    esac
}

# Load initial wallpapers for visible workspaces
initial_load() {
    local commands=()
    local workspaces=$(get_visible_workspaces)

    while read -r i; do
        wallpaper=$(set_wallpaper "$i")
        if [[ -n $wallpaper ]]; then
            # Directly assign the socket without arithmetic
            socket="$MPV_SOCK_L"
            if (( i % 2 == 0 )); then
                socket="$MPV_SOCK_R"
            fi
            commands+=("loadfile \"$wallpaper\"")
        fi
    done <<< "$workspaces"

    # Send all commands at once to socat
    if [ "${#commands[@]}" -gt 0 ]; then
        # Execute the command to change the wallpaper in the background
        {
            (IFS=$'\n'; echo "${commands[*]}")
        } | socat - "$MPV_SOCK_L" &
        {
            (IFS=$'\n'; echo "${commands[*]}")
        } | socat - "$MPV_SOCK_R" &
    fi
}

# Load initial wallpapers
initial_load

# Handle workspace changes and update wallpapers
handle_workspace_change() {
    swaymsg -t subscribe -m '[ "workspace" ]' | while read -r event; do
        workspace_num=$(echo "$event" | jq -r '.current.num')
        wallpaper=$(set_wallpaper "$workspace_num")

        if [[ -n $wallpaper ]]; then
            # Determine the socket based on the workspace number
            socket="$MPV_SOCK_L"
            if (( workspace_num % 2 == 0 )); then
                socket="$MPV_SOCK_R"
            fi
            
            # Start timing for wallpaper change
            change_start_time=$(date +%s%3N)  # Current time in milliseconds

            # Execute the command to change the wallpaper in the background
            {
                echo "loadfile \"$wallpaper\""
            } | socat - "$socket" &

            # End timing for wallpaper change
            change_end_time=$(date +%s%3N)  # Current time in milliseconds
            change_elapsed_time=$(( change_end_time - change_start_time ))  # Calculate elapsed time in ms
            echo "Wallpaper change time for workspace $workspace_num: $change_elapsed_time ms"
        fi
    done
}

# Start listening for workspace changes
handle_workspace_change &

# Wait for the background job to finish (it won't, as it's an infinite loop)
wait

# End timer and calculate elapsed time
end_time=$(date +%s%3N)  # Current time in milliseconds
elapsed_time=$(( end_time - start_time ))  # Total execution time in ms

# Print the elapsed time
echo "Total execution time: $elapsed_time ms"
