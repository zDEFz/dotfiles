#!/bin/bash

# Sleep if the --sleep flag is provided
if [[ "$1" == "--sleep" ]]; then
    sleep 15
fi

# Define variables
script=~/.config/sway/scripts/alacritty-micro-stickies/micro-stickies.bash
notes_dir="/home/blu/notes"

# Array of stickies to launch
declare -a stickies=(
    "blue ${notes_dir}/ws-31/wanikani-cheat"
    "transparent ${notes_dir}/ws-04/intake"
    "transparent ${notes_dir}/ws-04/wellbeing"
)

# Launch each sticky note with a slight delay
for sticky in "${stickies[@]}"; do
    $script "$sticky" --startup &
    sleep 0.24
done