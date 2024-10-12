#!/bin/bash

b="$HOME/mpvsock-bg-"
MPV_L_WALL_PATH="/home/blu/.config/sway/wallpaper/L_SCREEN/"
MPV_R_WALL_PATH="/home/blu/.config/sway/wallpaper/R_SCREEN/"
MPV_SOCK_L="${b}left"
MPV_SOCK_R="${b}right"

FIRST_RUN=false

# Start mpvpaper instances for left and right monitors
mpvpaper -f -o "input-ipc-server=$MPV_SOCK_L --no-keepaspect-window" -n 10 'DP-2' null &
mpvpaper -f -o "input-ipc-server=$MPV_SOCK_R --no-keepaspect-window" -n 10 'DP-1' null &

# Function to set the wallpaper for a monitor based on workspace number
set_wallpaper() {
    workspace_num="$1"

    # Determine wallpaper based on workspace number
    case $workspace_num in
        1) echo "${MPV_L_WALL_PATH}22BW73_resized.png" ;;
        2) echo "${MPV_R_WALL_PATH}4K - _vectorpaper__tatsumaki_by_azizkeybackspace-d9gq3v7(noise_scale)(x2.0)(level1).png" ;;
        3) echo "${MPV_L_WALL_PATH}002e1ab4d079c20f36dbefdf83aa73ee_001(noise_scale)(x2.0)(level1)_cr.png" ;;
        *) return ;;  # No wallpaper for other workspaces
    esac
}

# Get the list of visible workspaces
visible_workspaces=$(swaymsg -t get_workspaces | jq -r '.[] | select(.visible == true) | .num')

echo $visible_workspaces

while true; do
    # Get the list of visible workspaces
    visible_workspaces=$(swaymsg -t get_workspaces | jq -r '.[] | select(.visible == true) | .num')

    echo "Visible Workspaces: $visible_workspaces"

    # Iterate through visible workspaces
    for i in $visible_workspaces; do
        wallpaper=$(set_wallpaper $i)
        
        # Output the current workspace and its wallpaper
        echo "============================"
        echo "Workspace: $i"
        echo "Wallpaper: '$wallpaper'"
        
        if [[ -n $wallpaper ]]; then
            # Check if the workspace index is odd or even
            if [[ $((i % 2)) -ne 0 ]]; then
                echo "Action: Setting wallpaper on the LEFT screen (SCREEN_L)"
                # Send command to load wallpaper to the left screen
                echo "loadfile \"$wallpaper\"" | socat - "$HOME/mpvsock-bg-left"
            else
                echo "Action: Setting wallpaper on the RIGHT screen (SCREEN_R)"
                # Send command to load wallpaper to the right screen
                echo "loadfile \"$wallpaper\"" | socat - "$HOME/mpvsock-bg-right"
            fi
        else
            echo "Status: No wallpaper set for workspace $i."
        fi

        echo "============================"
    done
    
    FIRST_RUN=true

    # if first run=true, use swaymsg -t subscribe '["workspace"]' | while read -r event; do
done





