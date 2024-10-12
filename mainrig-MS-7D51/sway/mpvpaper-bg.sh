#!/bin/bash
b="/tmp/mpvsock-bg-"
DEFAULT_IMG="default.png"  # Unused variable; consider removing if not needed.
MPV_L_WALL_PATH="/home/blu/.config/sway/wallpaper/L_SCREEN/"
MPV_R_WALL_PATH="/home/blu/.config/sway/wallpaper/R_SCREEN/"
MPV_SOCK_L="${b}left"
MPV_SOCK_R="${b}right"

# Start mpvpaper instances for left and right monitors
mpvpaper -f -o "input-ipc-server=$MPV_SOCK_L --no-keepaspect-window" -n 10 'DP-2' null &
mpvpaper -f -o "input-ipc-server=$MPV_SOCK_R --no-keepaspect-window" -n 10 'DP-1' null &

# Function to load the wallpaper for left monitor based on workspace number
load_wallpaper_left() {
    workspace_num="$1"  # Quote to prevent globbing and word splitting
    echo "workspace no $workspace_num"  # Quote for consistency

    case $workspace_num in
        1) wallpaper="22BW73_resized.png" ;;
        3) wallpaper="005 - RLKrR5h_cr.jpg" ;;
        *) wallpaper="$DEFAULT_IMG" ;;  # Default fallback wallpaper
    esac

    echo "wallpaper $wallpaper"  # Quote for consistency

    echo "loadfile ${MPV_L_WALL_PATH}${wallpaper}" | socat - "$MPV_SOCK_L"
}

# Function to load the wallpaper for right monitor based on workspace number
load_wallpaper_right() {
    workspace_num="$1"  # Quote to prevent globbing and word splitting
    echo "workspace no $workspace_num"  # Quote for consistency

    case $workspace_num in
        2) wallpaper="4K - _vectorpaper__tatsumaki_by_azizkeybackspace-d9gq3v7(noise_scale)(x2.0)(level1).png" ;;
        *) wallpaper="$DEFAULT_IMG" ;;  # Default fallback wallpaper
    esac

    echo "wallpaper $wallpaper"  # Quote for consistency

    echo "loadfile ${MPV_R_WALL_PATH}${wallpaper}" | socat - "$MPV_SOCK_R"
}

# Main loop to listen for workspace changes and update wallpapers
while true; do
    swaymsg -t subscribe '["workspace"]' | while read -r event; do
        # Get the current workspace number
        workspace_num=$(swaymsg -t get_workspaces | jq '.[] | select(.focused == true).num')

        # Load the appropriate wallpaper for left and right monitors
        load_wallpaper_left "$workspace_num"
        load_wallpaper_right "$workspace_num"
    done
done
