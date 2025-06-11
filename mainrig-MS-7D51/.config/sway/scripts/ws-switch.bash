#!/bin/bash

monitors=(LL L M R RR MON_KB)  # Define monitors
GROUP_SIZE=${#monitors[@]}      # Number of groups

# Get the current focused workspace number
current_ws=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true).name' | grep -o '[0-9]\+')

# Calculate the group index based on the current workspace
group_index=$(( (current_ws - 1) / GROUP_SIZE ))

# Move to next or previous group
if [ "$1" == "next" ]; then
    next_group_start=$(( (group_index + 1) * GROUP_SIZE + 1 ))
    echo "Switching to next group: $next_group_start to $((next_group_start + GROUP_SIZE - 1))"
    swaymsg "workspace $next_group_start, workspace $((next_group_start + 1)), workspace $((next_group_start + 2)), workspace $((next_group_start + 3)), workspace $((next_group_start + 4)), workspace $((next_group_start + 5))"
fi

if [ "$1" == "prev" ]; then
    if [ "$group_index" -gt 0 ]; then
        prev_group_start=$(( (group_index - 1) * GROUP_SIZE + 1 ))
        echo "Switching to previous group: $prev_group_start to $((prev_group_start + GROUP_SIZE - 1))"
        swaymsg "workspace $prev_group_start, workspace $((prev_group_start + 1)), workspace $((prev_group_start + 2)), workspace $((prev_group_start + 3)), workspace $((prev_group_start + 4)), workspace $((prev_group_start + 5))"
    else
        echo "Already at the first group"
    fi
fi
