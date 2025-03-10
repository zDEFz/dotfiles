#!/bin/bash

# Find the window ID of Cultris II
cultris_window_id=$(xdotool search --name "Cultris II")

# Check if the window ID was found
if [ -n "$cultris_window_id" ]; then
    # Kill the Cultris II window specifically
    xdotool windowkill "$cultris_window_id"
else
    # Kill the currently active window
    i3-msg kill
fi
