#!/bin/bash

# Reload Sway
swaymsg reload

# Busy-wait until Sway is responsive
while ! swaymsg -t get_tree >/dev/null 2>&1; do :; done

# Kill lingering swaybar processes
killall -q swaybar

# Busy-wait until all swaybar processes have stopped
while pgrep -x swaybar > /dev/null; do :; done

# Start all 7 swaybars in parallel
for i in {1..3}; do
  swaymsg "exec --no-startup-id swaybar --bar_id=bar-$i" &
done

# Play audio in the background
pw-play '/home/blu/audio/FX/Pokemon/156 - quilava.mp3' &
