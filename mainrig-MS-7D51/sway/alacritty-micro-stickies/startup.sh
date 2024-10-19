#!/bin/bash
#sleep 15

if [[ "$1" == "--sleep" ]]; then
    sleep 15
fi

script=/home/blu/.config/sway/alacritty-micro-stickies/micro-stickies.sh

# LL screen

    LL_SCREEN_pos01_portrait="0   0"
    LL_SCREEN_pos02_portrait="640 0"               

    LL_SCREEN_pos10_portrait="0   500"               
    LL_SCREEN_pos11_portrait="640 500"             

    LL_SCREEN_pos20_portrait="0   1000"              
    LL_SCREEN_pos21_portrait="640 1000"            

    LL_SCREEN_pos30_portrait="0   1500"              
    LL_SCREEN_pos31_portrait="640 1500"    

    LL_SCREEN_pos40_portrait="0   2000"              
    LL_SCREEN_pos41_portrait="640 2000"    

# RR screen
    RR_SCREEN_pos01_portrait="4080 14"             
    RR_SCREEN_pos02_portrait="4670 14"             

    RR_SCREEN_pos10_portrait="4080 514"            
    RR_SCREEN_pos11_portrait="4670 512"       

    RR_SCREEN_pos20_portrait="4080 1014"           
    RR_SCREEN_pos21_portrait="4670 1014"           

    RR_SCREEN_pos30_portrait="4080 1514"           
    RR_SCREEN_pos31_portrait="4670 1514"           

    RR_SCREEN_pos40_portrait="4080 2014"           
    RR_SCREEN_pos41_portrait="4670 2014"           

# R screen
R_SCREEN_BOTTOM_RIGHT="3581 949"    

p="/home/blu/notes"

$script "transparent ${p}/ws-04/sap-talk-I-was"    --startup "4" "$RR_SCREEN_pos01_portrait" &
    sleep .25
$script "transparent ${p}/ws-04/sap-talk-become"   --startup "4" "$RR_SCREEN_pos02_portrait" &
    sleep .25
$script "transparent ${p}/ws-04/sap-talk-myself"   --startup "4" "$RR_SCREEN_pos10_portrait" &
    sleep .25
$script "transparent ${p}/ws-04/workout"           --startup "4" "$RR_SCREEN_pos11_portrait" &
    sleep .25
$script "transparent ${p}/ws-04/mind"              --startup "4" "$RR_SCREEN_pos20_portrait" &
    sleep .25
$script "transparent ${p}/ws-04/health"            --startup "4" "$RR_SCREEN_pos21_portrait" &
    sleep .25
$script "transparent ${p}/ws-04/groceries"         --startup "4" "$RR_SCREEN_pos30_portrait" &
    sleep .25
$script "transparent ${p}/ws-04/todo"              --startup "4" "$RR_SCREEN_pos31_portrait" &
    sleep .25
# Wanikani bottom right
$script "blue ${p}/ws-31/jap-cheat"                --startup "31"   "$R_SCREEN_BOTTOM_RIGHT" &
    
#     $script "transparent workout"                --startup    "52" "3707 820"
