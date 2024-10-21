#!/bin/bash

# Set the color variable based on user input (blue or orange)
micro_args="-colorscheme $1"
mode="$2"
pos_args=""
workspace="$3"

if [[ $mode == "--startup" ]]; then
   swaymsg "focus output 'BNQ ZOWIE XL LCD EBMCM01300SL0"
   swaymsg workspace $3
   sleep .1
   pos_args="move absolute position $4"
fi

if [[ $mode == "--cursor" ]]; then
  pos_args="move position cursor"
fi

# Generate a unique ID using the current timestamp and a random hex value
timestamp=$(date +%s)
random_hex=$(printf "%x" $((RANDOM)))
unique_id="${timestamp}-${random_hex}"

# Specify the width and height for the Alacritty window
width=500
height=498

# Launch Alacritty with the unique ID as part of the class name and disown the process
alacritty \
--class="alacritty-micro-$unique_id" \
-e micro $micro_args &


# Give Alacritty time to launch
sleep .4

# Move and resize the newly created Alacritty window to the cursor position or specified position
swaymsg "[app_id=\"alacritty-micro-$unique_id\"] floating enable, resize set ${width} ${height}, ${pos_args}, border none"
