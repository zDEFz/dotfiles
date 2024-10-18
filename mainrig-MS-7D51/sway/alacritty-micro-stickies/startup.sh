#!/bin/bash
sleep 15
script=/home/blu/.config/sway/alacritty-micro-stickies/micro-stickies.sh

# Wanikani bottom right
    $script "transparent jap-cheat" --startup "24" "3581 949"

# LL screen

    LL_SCREEN_pos01_portrait="0 0"                 
    LL_SCREEN_pos02_portrait="500 0"               

    LL_SCREEN_pos10_portrait="0 500"               
    LL_SCREEN_pos11_portrait="500 500"             

    LL_SCREEN_pos20_portrait="0 1000"              
    LL_SCREEN_pos21_portrait="500 1000"            

    LL_SCREEN_pos30_portrait="0 1500"              
    LL_SCREEN_pos31_portrait="500 1500"    

    LL_SCREEN_pos40_portrait="0 2000"              
    LL_SCREEN_pos41_portrait="500 2000"    

# RR screen
    RR_SCREEN_pos01_portrait="4080 0"             
    RR_SCREEN_pos02_portrait="4580 0"             

    RR_SCREEN_pos10_portrait="4080 500"            
    RR_SCREEN_pos11_portrait="4580 500"       

    RR_SCREEN_pos20_portrait="4080 1000"           
    RR_SCREEN_pos21_portrait="4580 1000"           

    RR_SCREEN_pos30_portrait="4080 1500"           
    RR_SCREEN_pos31_portrait="4580 1500"           

    RR_SCREEN_pos40_portrait="4080 2000"           
    RR_SCREEN_pos41_portrait="4580 2000"           

$script "transparent sap-talk-I-was"    --startup "00" "$RR_SCREEN_pos01_portrait"
$script "transparent sap-talk-become"   --startup "00" "$RR_SCREEN_pos02_portrait"

$script "transparent sap-talk-myself"   --startup "00" "$RR_SCREEN_pos10_portrait"
$script "transparent sap-talk-I-am"     --startup "00" "$RR_SCREEN_pos11_portrait"

$script "transparent mind"              --startup "00" "$RR_SCREEN_pos20_portrait"
$script "transparent health"            --startup "00" "$RR_SCREEN_pos21_portrait"

$script "transparent groceries"         --startup "00" "$RR_SCREEN_pos30_portrait"
$script "transparent todo  "            --startup "00" "$RR_SCREEN_pos31_portrait"
    
#     $script "transparent workout"                                 --startup    "52" "3707 820"
