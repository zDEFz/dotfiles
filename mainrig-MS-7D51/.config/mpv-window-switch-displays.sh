#!/bin/bash

# Get the active display
active_display=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).output')

# Debugging: Print the active display
echo "Active display: $active_display"

# Determine next output
if [ "$active_display" == "DP-3" ]; then
    next_output="DP-1"
elif [ "$active_display" == "DP-1" ]; then
    next_output="DP-3"
else
    echo "Unknown active display: $active_display"
    exit 1
fi

# Debugging: Print the next output
echo "Next output: $next_output"

# Move to next output using i3-msg
result=$(i3-msg move to output "$next_output"; i3-msg focus parent)
xdotool windowfocus "$(xdotool search --name "video0 - mpv")"

# Debugging: Print the result of i3-msg
echo "i3-msg result: $result"
