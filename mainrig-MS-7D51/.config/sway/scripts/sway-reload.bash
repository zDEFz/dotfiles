#!/bin/bash

# Reload Sway
echo "Reloading Sway..."
swaymsg reload

# Kill lingering swaybar processes
echo "Killing any lingering swaybar processes..."
killall -q swaybar

# Start all 7 bars in parallel
echo "Starting 7 swaybars..."
for i in {1..7}; do
  swaymsg "exec --no-startup-id swaybar --bar_id=bar-$i" &
done

# Play the audio in the background
echo "Playing audio: Pokemon - 156 - Quilava..."
pw-play '/mnt/storage/audio/MusicLibrary/FX/Pokemon/156 - quilava.mp3' &
