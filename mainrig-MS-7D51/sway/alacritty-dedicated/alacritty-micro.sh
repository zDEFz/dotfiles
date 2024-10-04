#!/bin/bash

# Set the color variable based on user input (blue or orange)

micro_args="-colorscheme $1"

# Generate a unique ID using the current timestamp and a random hex value
unique_id=$(printf "%x" $(( $(date +%s%N) + RANDOM )))

# Specify the width and height for the Alacritty window
width=394
height=247

# Launch Alacritty with the unique ID as part of the class name and disown the process
alacritty --working-directory="/home/blu/notes" \
--class="alacritty-micro-$unique_id" \
-e micro $micro_args &

# Give Alacritty time to launch
sleep .3

# Move and resize the newly created Alacritty window to the cursor position
swaymsg "[app_id=\"alacritty-micro-$unique_id\"] floating enable, resize set ${width} ${height}, move position cursor"
