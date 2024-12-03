#!/bin/bash

# Define variables for monitor identifiers
LL="Iiyama North America PL2590HS 1219241201677"
L="BNQ ZOWIE XL LCD EBX7M01214SL0"
M="BNQ ZOWIE XL LCD EBF2R02370SL0"
MON_KB="Iiyama North America PL2590HS 1219241201302"
R="BNQ ZOWIE XL LCD EBMCM01300SL0"
RR="Iiyama North America PL2590HS 1219241201699"
TAIKO="Iiyama North America PL2590HS 1219241201616"

set_defaults() {
	swaymsg reload
}

set_workaround() {
    swaymsg mouse_warping output

    swaymsg "output '$MON_KB' position 0 0"
     
    swaymsg "output '$LL' position 1920 350"
    swaymsg "output '$L' position 3000 350"
    swaymsg "output '$M' position 4080 464"
    swaymsg "output '$R' position 6000 354"
    swaymsg "output '$RR' position 7080 384"
    swaymsg "output '$TAIKO' position 8160 384"
}



# Display help message
show_help() {
    echo "Usage: $0 [default|workaround|help]"
    echo
    echo "Commands:"
    echo "  default     Set the default monitor positions"
    echo "  workaround  Apply workaround positions for monitors"
    echo "  help        Display this help message"
}

finishing() {
	# Kill lingering swaybar processes
	echo "Killing any lingering swaybar processes..."
	killall -q swaybar
	
	# Start all 7 bars in parallel
	echo "Starting 7 swaybars..."
	for i in {1..7}; do
	  swaymsg "exec --no-startup-id swaybar --bar_id=bar-$i" &
	done
	
}

focus_fruity_loops_and_maximize() { 
	swaymsg '[class=^fl64.exe$] focus, fullscreen enable'
	pw-play '/mnt/storage/audio/MusicLibrary/FX/Pokemon/156 - quilava.mp3' &
}

focus_fruity_undo_fullscreen() { 
	swaymsg '[class=^fl64.exe$] focus, fullscreen disable'
		ffmpeg -i '/mnt/storage/audio/MusicLibrary/FX/Pokemon/156 - quilava.mp3' -af areverse -f s16le -ar 44100 -ac 2 - | aplay -f S16_LE -r 44100 -c 2 &
		
}

# Handle arguments
case "$1" in
    default)
        set_defaults
        finishing
        focus_fruity_undo_fullscreen
        ;;
    workaround)
        set_workaround
        finishing
        focus_fruity_loops_and_maximize
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Invalid option '$1'"
        show_help
        exit 1
        ;;
esac
