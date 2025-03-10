#!/bin/bash

# Get app_id for the focused window
app_id=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .app_id // empty')
echo "$app_id"
