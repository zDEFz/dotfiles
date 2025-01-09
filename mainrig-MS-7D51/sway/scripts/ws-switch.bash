#!/bin/bash

# Define paths and file locations
TEMPLATE_FILE="/home/blu/.config/sway/conf.d/workspaces/template-assignfile"

# Group settings
GROUP_SIZE=7  # Adjusted to 7 workspaces per group (LL, L, M, R, RR, TAIKO, MON_KB)

# Focused workspace retrieval
CURRENT_WORKSPACE=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused == true) | .name | tonumber')

# Function to count the total number of workspaces (based on how many IDs we have in the file)
count_total_workspaces() {
    local file_path=$1
    # Extract workspace numbers (using regex to match ws<number>-<type>) and count unique workspace IDs
    total_workspaces=$(grep -oP 'ws\d+' "$file_path" | sort -u | wc -l)
    
    if [ "$total_workspaces" -le 0 ]; then
        echo "No workspaces found in $file_path."
        exit 1
    fi

    echo "$total_workspaces"
}

# Get the total number of workspaces from the template file
TOTAL_WORKSPACES=$(count_total_workspaces "$TEMPLATE_FILE")
echo "Total workspaces: $TOTAL_WORKSPACES"

# Calculate the current group based on the current workspace number
CURRENT_GROUP=$(( (CURRENT_WORKSPACE - 1) / GROUP_SIZE ))

# Determine the next or previous group based on the argument
if [ "$1" == "next" ]; then
    NEXT_GROUP=$((CURRENT_GROUP + 1))
else
    NEXT_GROUP=$((CURRENT_GROUP - 1))
fi

# Calculate the starting workspace for the next or previous group
START_WORKSPACE=$((NEXT_GROUP * GROUP_SIZE + 1))

# Check if the start workspace is out of bounds
if [ "$START_WORKSPACE" -le 0 ]; then
    echo "You are already at the first group."
    exit 1
fi

if [ "$START_WORKSPACE" -gt "$TOTAL_WORKSPACES" ]; then
    echo "No more workspaces available."
    exit 1
fi

# Create the list of workspaces to switch to
WORKSPACE_LIST=""
for ((i = 0; i < GROUP_SIZE; i++)); do
    WORKSPACE_NUM=$((START_WORKSPACE + i))
    if [ "$WORKSPACE_NUM" -le "$TOTAL_WORKSPACES" ]; then
        if [ -n "$WORKSPACE_LIST" ]; then
            WORKSPACE_LIST+=", "
        fi
        WORKSPACE_LIST+="workspace $WORKSPACE_NUM"
    fi
done

# Debugging output to confirm which workspaces are being switched to
echo "Switching to workspaces: $WORKSPACE_LIST"

# Echo the exact swaymsg command being executed
echo "Executing: swaymsg workspace $WORKSPACE_LIST"

# Switch to the specified workspaces
swaymsg "workspace $WORKSPACE_LIST"

# Check if swaymsg reported any errors or warnings
if [ $? -ne 0 ]; then
    echo "Error executing swaymsg. Please check the command and your Sway configuration."
fi

# Focus the specific output 'BNQ ZOWIE XL LCD EBF2R02370SL0'
swaymsg "focus output 'BNQ ZOWIE XL LCD EBF2R02370SL0'"

# Output the workspace list
echo "Switched to: $WORKSPACE_LIST"
