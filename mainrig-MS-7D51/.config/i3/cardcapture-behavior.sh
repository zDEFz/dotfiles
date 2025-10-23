#!/bin/bash

behave() 
{
# Specify the initial output
current_output="DP-1"

# Get the window ID of the specified window
window_id=$(xdotool search --classname "mpvcapturecard")

# Check if the window ID is valid
if [ -n "$window_id" ]; then
    # Get the position of the window
    window_position=$(xdotool getwindowgeometry --shell "$window_id")

    # Extract the X coordinate from the window position
    window_x=$(echo "$window_position" | grep "X=" | cut -d "=" -f 2)

    # Check if the window is on the rightmost screen (DP-3)
    if [ "$window_x" -ge 1920 ]; then
        current_output="DP-3"
    fi

    # Check if the window is focused
    if xdotool getwindowfocus | grep -q "$window_id"; then
        echo "The window is focused."
        # Toggle fullscreen
        i3-msg fullscreen toggle
        # Move to the current output
        i3-msg move to output "$current_output"
        # Focus the window on the right side
        i3-msg focus right
    else
        echo "The window is not focused."
    fi
else
    echo "Window not found."
fi
}

while true; do behave; sleep .2; done
