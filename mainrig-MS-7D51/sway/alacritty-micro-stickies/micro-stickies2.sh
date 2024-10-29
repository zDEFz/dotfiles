#!/bin/bash

# Assign arguments to variables
colorscheme="$1"
file="$2"
mode="$3"

# Set the color scheme for micro
micro_args="--colorscheme $colorscheme"


# Set startup or cursor mode based on the third argument
case "$mode" in
  --startup)
    pos_args="move to output 'BNQ ZOWIE XL LCD EBMCM01300SL0'"
    ;;
  --cursor)
    pos_args="move position cursor"
    ;;
esac

# Generate a unique ID using the current timestamp and a random hex value
unique_id=$(printf "%x" $(( $(date +%s%N) + RANDOM )))

# Specify the width and height for the Alacritty window
width=394
height=527

# Launch Alacritty with the unique ID as part of the class name and disown the process
alacritty --working-directory="/home/blu/notes" \
--class="alacritty-micro-$unique_id" \
-e micro $micro_args "$file" &

# Give Alacritty time to launch
sleep 0.5

# Move and resize the newly created Alacritty window to the specified position
swaymsg "[app_id=\"alacritty-micro-$unique_id\"] floating enable, resize set ${width} ${height}, ${pos_args}"
