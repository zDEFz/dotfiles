#!/bin/bash

# Set the color variable based on user input (blue or orange)
micro_args="-colorscheme $1"
mode="$2"
pos_args=""
workspace="$3"

# echo $3

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
name="$1"

# Specify the width and height for the Alacritty window
width=500
height=498

# Launch Alacritty with the unique ID as part of the class name and disown the process
alacritty --working-directory="/home/blu/notes" \
--class="alacritty-micro-$name" \
-e micro $micro_args &

# Give Alacritty time to launch
sleep .5
# echo ${pos_args}

# Move and resize the newly created Alacritty window to the cursor position
swaymsg "[app_id=\"alacritty-micro-$name\"] floating enable, resize set ${width} ${height}, ${pos_args}, border none"