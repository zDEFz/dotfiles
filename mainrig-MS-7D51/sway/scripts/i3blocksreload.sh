#!/bin/bash
killall swaybar
swaymsg "exec --no-startup-id swaybar --bar_id=bar-1"
swaymsg "exec --no-startup-id swaybar --bar_id=bar-2"
swaymsg "exec --no-startup-id swaybar --bar_id=bar-3"
swaymsg "exec --no-startup-id swaybar --bar_id=bar-4"
swaymsg "exec --no-startup-id swaybar --bar_id=bar-5"
swaymsg "exec --no-startup-id swaybar --bar_id=bar-6"
