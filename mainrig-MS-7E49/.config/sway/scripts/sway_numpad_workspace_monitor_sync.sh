#!/bin/bash

KEY_NUM=$1
START_OFFSET=$2

# 1. Get ACTIVE outputs and SORT them by physical X position (Left to Right)
MAP_DATA=$(swaymsg -t get_outputs | jq -r '.[] | select(.active == true and .power == true) | "\(.rect.x) \(.name)"' | sort -n | awk '{print $2}')
OUTPUTS=($MAP_DATA)
MONITOR_COUNT=${#OUTPUTS[@]}

[ "$MONITOR_COUNT" -le 0 ] && exit 1

# 2. Calculate the base workspace for this keypad group
group_offset=$(( (KEY_NUM - 1) * MONITOR_COUNT ))
current_start=$(( START_OFFSET + group_offset ))

CMD_PARTS=()
SWITCH_PARTS=()

# 3. Assign workspaces to the monitors found (1 to N)
for i in "${!OUTPUTS[@]}"; do
    ws_num=$(( current_start + i ))
    output_name="${OUTPUTS[$i]}"
    
    # Assign the workspace to that specific physical monitor
    CMD_PARTS+=("workspace $ws_num output $output_name")
    SWITCH_PARTS+=("workspace $ws_num")
done

# 4. Focus Logic: Always focus the LAST monitor (Your MON_KB)
# In your 6-monitor setup, MON_KB is the 6th. In a 4-monitor setup, the 4th becomes the 'edge'.
focus_idx=$(( MONITOR_COUNT - 1 ))
target_ws=$(( current_start + focus_idx ))

# 5. Join and Execute
# We map them, switch to all of them to update the workspace bar, then focus the main one
COMMANDS=$(IFS=', '; echo "${CMD_PARTS[*]}, ${SWITCH_PARTS[*]}, workspace $target_ws")
swaymsg "$COMMANDS"