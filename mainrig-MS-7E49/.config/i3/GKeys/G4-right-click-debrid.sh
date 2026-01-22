#!/bin/bash

# Ensure the window is focused
#xdotool search --onlyvisible --class "your-browser-class" windowactivate

# Perform a right-click
xdotool click 3
sleep 0.1

# Press 'l' key to focus on the address bar
xdotool key l

# Open a new tab
xdotool key ctrl+t
sleep 0.1

# Type the URL
xdotool type "https://real-debrid.com/torrents"
sleep 0.1

# Press 'Return' to load the URL
xdotool key Return
