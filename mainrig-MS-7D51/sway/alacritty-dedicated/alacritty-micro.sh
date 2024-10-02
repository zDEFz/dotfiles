#!/bin/bash

# Generate a unique ID using the current timestamp and a random hex value
unique_id=$(printf "%x" $(( $(date +%s%N) + RANDOM )))

# Specify the width and height for the Alacritty window
width=400
height=250

# Launch Alacritty with the unique ID as part of the class name and disown the process
alacritty --class="alacritty-micro-$unique_id" -e micro &

# Give Alacritty time to launch
sleep .2

# Move and resize the newly created Alacritty window to the cursor position
swaymsg "[app_id=\"alacritty-micro-$unique_id\"] floating enable, resize set ${width} ${height}, move position cursor"
