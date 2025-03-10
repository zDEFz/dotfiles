#!/bin/bash

killall -q swaybar   # Ensure no lingering swaybar processes without output

# Parallel execution of all swaymsg commands (no wait)
swaymsg "exec --no-startup-id swaybar --bar_id=bar-{1..7}" &
