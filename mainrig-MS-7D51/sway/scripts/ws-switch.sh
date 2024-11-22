#!/bin/bash

# Define paths and file locations
TEMPLATE_FILE="/home/blu/.config/sway/workspaces/template-assignfile"

# Group settings
GROUP_SIZE=6  # Adjusted to 6 workspaces per group

# Focused workspace retrieval
CURRENT_WORKSPACE=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused == true) | .name | tonumber')

# Function to count the total number of workspaces (based on how many IDs we have in the file)
count_total_workspaces() {
    local file_path=$1
    # Count how many workspace IDs exist in the file
    total_workspaces=$(grep -oP '\(\K[0-9]+' "$file_path" | wc -l)
    
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

# Switch to the specified workspaces
swaymsg "$WORKSPACE_LIST"

# Focus the specific output 'BNQ ZOWIE XL LCD EBF2R02905SL0'
swaymsg "focus output 'BNQ ZOWIE XL LCD EBF2R02905SL0'"

# Output the workspace list
echo "Switched to: $WORKSPACE_LIST"
