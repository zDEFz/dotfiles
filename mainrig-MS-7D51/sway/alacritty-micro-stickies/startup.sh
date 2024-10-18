#!/bin/bash
#sleep 15

if [[ "$1" == "--sleep" ]]; then
    sleep 15
fi

script=/home/blu/.config/sway/alacritty-micro-stickies/micro-stickies.sh



# LL screen

    LL_SCREEN_pos01_portrait="0 0"                 
    LL_SCREEN_pos02_portrait="640 0"               

    LL_SCREEN_pos10_portrait="0 500"               
    LL_SCREEN_pos11_portrait="640 500"             

    LL_SCREEN_pos20_portrait="0 1000"              
    LL_SCREEN_pos21_portrait="640 1000"            

    LL_SCREEN_pos30_portrait="0 1500"              
    LL_SCREEN_pos31_portrait="640 1500"    

    LL_SCREEN_pos40_portrait="0 2000"              
    LL_SCREEN_pos41_portrait="640 2000"    

# RR screen
    RR_SCREEN_pos01_portrait="4080 0"             
    RR_SCREEN_pos02_portrait="4670 0"             

    RR_SCREEN_pos10_portrait="4080 500"            
    RR_SCREEN_pos11_portrait="4670 500"       

    RR_SCREEN_pos20_portrait="4080 1000"           
    RR_SCREEN_pos21_portrait="4670 1000"           

    RR_SCREEN_pos30_portrait="4080 1500"           
    RR_SCREEN_pos31_portrait="4670 1500"           

    RR_SCREEN_pos40_portrait="4080 2000"           
    RR_SCREEN_pos41_portrait="4670 2000"           

$script "transparent sap-talk-I-was"    --startup "00" "$RR_SCREEN_pos01_portrait" &
sleep .18
$script "transparent sap-talk-become"   --startup "00" "$RR_SCREEN_pos02_portrait" &
sleep .18
$script "transparent sap-talk-myself"   --startup "00" "$RR_SCREEN_pos10_portrait" &
sleep .18
$script "transparent workout"           --startup "00" "$RR_SCREEN_pos11_portrait" &
sleep .18
$script "transparent mind"              --startup "00" "$RR_SCREEN_pos20_portrait" &
sleep .18
$script "transparent health"            --startup "00" "$RR_SCREEN_pos21_portrait" &
sleep .18
$script "transparent groceries"         --startup "00" "$RR_SCREEN_pos30_portrait" &
sleep .18
$script "transparent todo"            --startup "00" "$RR_SCREEN_pos31_portrait" &

sleep .18
# Wanikani bottom right
    $script "transparent jap-cheat" --startup "24" "3581 949" &
    
#     $script "transparent workout"                                 --startup    "52" "3707 820"
