#!/bin/bash

# Check if Cultris II window is found
if xdotool search --name "Cultris II" &> /dev/null; then
    # If found, kill the active window
    xdotool getactivewindow windowkill
else
    # If not found, just kill
    i3-msg kill
fi
