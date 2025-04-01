#!/bin/bash
if [[ "$1" == "--sleep" ]]; then
    sleep 15
fi

script=~/.config/sway/scripts/alacritty-micro-stickies/micro-stickies.bash
p="/home/blu/notes"
$script "blue ${p}/ws-31/wanikani-cheat" --startup & sleep .24
$script "transparent ${p}/ws-04/intake" --startup & sleep .24
$script "transparent ${p}/ws-04/wellbeing" --startup & sleep .24
