#!/bin/bash

# Get the current focused workspace number
current_workspace=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused == true) | .name | tonumber')

# Group size (4 workspaces)
group_size=4

# Determine the current group
current_group=$(( (current_workspace - 1) / group_size ))

# Determine the next or previous group based on the argument
if [ "$1" == "next" ]; then
    next_group=$((current_group + 1))
else
    next_group=$((current_group - 1))
fi

# Calculate the starting workspace for the next or previous group
start_workspace=$((next_group * group_size + 1))

# Check for bounds (ensuring we don't go below 1 or exceed available workspaces)
total_workspaces=54  # Adjust this value based on your setup

if [ "$start_workspace" -le 0 ]; then
    echo "You are already at the first group."
    exit 1
fi

if [ "$start_workspace" -gt "$total_workspaces" ]; then
    echo "No more workspaces available."
    exit 1
fi

# Create the list of workspaces to switch to
workspace_list=""

for ((i = 0; i < group_size; i++)); do
    workspace_num=$((start_workspace + i))
    if [ "$workspace_num" -le "$total_workspaces" ]; then
        if [ -n "$workspace_list" ]; then
            workspace_list+=", "
        fi
        workspace_list+="workspace $workspace_num"
    fi
done

# Switch to the specified workspaces
swaymsg "$workspace_list"

# Focus the middle one of the new group
middle_workspace=$((start_workspace + (group_size / 2)))
swaymsg "workspace $middle_workspace"

# Output the workspace list
echo "Switched to: $workspace_list"
