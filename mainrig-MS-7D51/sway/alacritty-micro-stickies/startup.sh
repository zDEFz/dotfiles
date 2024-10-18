#!/bin/bash
#sleep 15
script=/home/blu/.config/sway/alacritty-micro-stickies/micro-stickies.sh

## LL Screen




# Wanikani bottom right
# $script "transparent jap-cheat" --startup "24" "3701 952"

    # $script "transparent firefox-tweaks"                         --startup    "1"


# LL screen

portrait=1080
landscape=1920

# Define positions using the portrait and landscape dimensions
pos01_portrait="0 0"                   # First row, first column
pos02_portrait="500 0"                 # First row, second column
pos10_portrait="0 500"                 # Second row, first column
pos11_portrait="500 500"               # Second row, second column
pos10_portrait="0 1000"                 # Third row, first column
pos11_portrait="500 1000"               # Third row, second colum


$script "transparent sap-talk-I-was"    --startup "00" "$pos01_portrait"
$script "transparent sap-talk-become"   --startup "00" "$pos02_portrait"
$script "transparent sap-talk-myself"   --startup "00" "$pos10_portrait"
$script "transparent sap-talk-I-am"     --startup "00" "$pos11_portrait"


# # # # Second Row
#     $script "transparent mind"                                   --startup    "52" "2163 820"
#     $script "transparent health"                                    --startup    "52" "2549 820"
#     $script "transparent groceries"                             --startup    "52" "2935 820"
#     $script "transparent todo"                                   --startup    "52" "3321 820"    
#     $script "transparent workout"                                   --startup    "52" "3707 820"
