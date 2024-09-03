#!/bin/bash
# Real current workspace

# Get current workspace name and convert it to a number, then adjust for even or odd
current_workspace=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused == true).name | tonumber | if . % 2 == 1 then . + 1 else . end')
echo "Current workspace: $current_workspace"

if [ "$1" == "next" ]; then
    nr=$((current_workspace + 2)) # Next on right monitor
    nl=$((current_workspace + 1)) # Next on left monitor
    swaymsg "workspace $nl; workspace $nr"
fi

if [ "$1" == "prev" ]; then
    nr=$((current_workspace - 2))
    nl=$((current_workspace - 3))
    echo "Previous right workspace: $nr"
    echo "Previous left workspace: $nl"
    if [ $nl -gt -1 ]; then
        swaymsg "workspace $nl; workspace $nr"
    else
        echo "Previous left workspace is out of bounds"
    fi
fi