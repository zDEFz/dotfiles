#!/bin/bash

# Serial number of the target display
target_serial="1219241201616"  # Replace with your actual serial number

# Function to get display name based on serial number from swaymsg
get_display_by_serial() {
    local serial="$1"

    # Run swaymsg to get connected outputs
    echo "Running swaymsg to detect displays..."
    swaymsg_output=$(swaymsg -t get_outputs -r)

    # Use jq to parse the JSON output and find the display associated with the serial number
    display_name=$(echo "$swaymsg_output" | jq -r ".[] | select(.serial == \"$serial\") | .name")

    # Debug: Show what was found for the display name
    echo "=== Debug: Found display name ==="
    if [[ -z "$display_name" ]]; then
        echo "Error: No display name found for serial number $serial."
        exit 1
    fi
    echo "Display name associated with serial $serial: $display_name"
    echo "==============================="
    
    echo "$display_name"
}

# Get the display name associated with the serial number
display_name=$(get_display_by_serial "$target_serial")

# Verify if a display was found
if [[ -z "$display_name" ]]; then
    echo "Error: No display found with serial number $target_serial."
    exit 1
fi

# Debug: Show final display name before using it
echo "=== Debug: Final display name ==="
echo "$display_name"
echo "==============================="


# Now you can run mpvpaper on the identified display
video_path="/home/blu/git/aerial-2k-videos/comp_CH_C007_C004_PSNK_v02_SDR_PS_FINAL_20180709_SDR_2K_HEVC.mov"
	echo "Starting mpvpaper with video: $video_path"
mpv --loop --x11-name=taiko_screen_screensaver --wayland-app-id=taiko_screen_screensaver --profile=fast "$video_path"
 
