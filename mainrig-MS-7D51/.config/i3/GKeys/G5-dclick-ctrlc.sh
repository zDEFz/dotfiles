#!/bin/bash

# Triple-click (left mouse button)
xdotool click --repeat 3 1

sleep 0.2

# Copy clipboard content
xdotool key ctrl+c
sleep 0.1
xdotool key ctrl+c

#Open a new tab
xdotool key ctrl+t

# Type the URL
xdotool type 'https://myanimelist.net/search/all?q='

# Paste clipboard content
xdotool key ctrl+v

# Press Enter
xdotool key Return
