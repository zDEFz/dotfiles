#!/bin/bash
swaymsg -t get_tree | jq -r '.. | select(.focused?).app_id' | tr -d '"'
