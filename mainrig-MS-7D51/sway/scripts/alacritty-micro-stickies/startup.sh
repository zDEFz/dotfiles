#!/bin/bash

if [[ "$1" == "--sleep" ]]; then
    sleep 15
fi

script=~/.config/sway/scripts/alacritty-micro-stickies/micro-stickies.sh

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
    RR_SCREEN_pos01_portrait="4080 42"             
    RR_SCREEN_pos02_portrait="4670 42"             

    RR_SCREEN_pos10_portrait="4080 542"            
    RR_SCREEN_pos11_portrait="4670 542"       

    RR_SCREEN_pos20_portrait="4080 1042"           
    RR_SCREEN_pos21_portrait="4670 1042"           

    RR_SCREEN_pos30_portrait="4080 1542"           
    RR_SCREEN_pos31_portrait="4670 1542"           

    RR_SCREEN_pos40_portrait="4080 2042"           
    RR_SCREEN_pos41_portrait="4670 2042"           

# R screen
R_SCREEN_BOTTOM_RIGHT="3581 949"    

p="/home/blu/notes"

#$script "transparent ${p}/ws-04/sap-talk-I-was"    --startup "4" "$RR_SCREEN_pos01_portrait" & sleep .24
    
#$script "transparent ${p}/ws-04/sap-talk-become"   --startup "4" "$RR_SCREEN_pos02_portrait" & sleep .24
    
#$script "transparent ${p}/ws-04/sap-talk-myself"   --startup "4" "$RR_SCREEN_pos10_portrait" & sleep .24
    
#$script "transparent ${p}/ws-04/workout"           --startup "4" "$RR_SCREEN_pos11_portrait" & sleep .24
   
 
   
$script "transparent ${p}/ws-04/intake" --startup & sleep .24
$script "transparent ${p}/ws-04/wellbeing" --startup & sleep .24


#$script "transparent ${p}/ws-04/supplements" --startup & sleep .24
    
#$script "transparent ${p}/ws-04/todo" --startup & sleep .24

#$script "transparent ${p}/ws-04/mind" --startup & sleep .24

#$script "transparent ${p}/ws-04/body" --startup & sleep .24

#$script "transparent ${p}/ws-04/i-am" --startup & sleep .24

#$script "transparent ${p}/ws-04/levetiracetam" --startup & sleep .24



# Wanikani bottom right
$script "blue ${p}/ws-31/wanikani-cheat" --startup & sleep .24
    
#     $script "transparent workout"                --startup    "52" "3707 820"