#!/bin/bash
killall swaybar
swaymsg "exec --no-startup-id swaybar --bar_id=bar-1"
swaymsg "exec --no-startup-id swaybar --bar_id=bar-2"
