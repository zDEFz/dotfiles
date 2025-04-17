#!/bin/bash

# ——— configure your active outputs here ———
monitors=(LL L M R RR MON_KB)
# monitors=(LL L M R RR TAIKO MON_KB)  # ← add/comment to include TAIKO

GROUP_SIZE=${#monitors[@]}

# Path to your template file
TEMPLATE_FILE="$HOME/.config/sway/conf.d/workspaces/template-assignfile"

# 1) figure out which numeric workspace you're on now
current_name=$(swaymsg -t get_workspaces \
    | jq -r '.[] | select(.focused) | .name')
if [[ $current_name =~ ^ws([0-9]+)- ]]; then
    CURRENT_WS_NUM=$((10#${BASH_REMATCH[1]}))
else
    echo "ERROR: couldn't parse current workspace name: $current_name"
    exit 1
fi

# 2) count how many distinct ws IDs are in your template file
TOTAL_WORKSPACES=$(grep -oP 'ws\K[0-9]+' "$TEMPLATE_FILE" \
    | sort -u | wc -l)
echo "Total workspaces defined: $TOTAL_WORKSPACES"

# 3) which group are we in? (0‑indexed)
CURRENT_GROUP=$(( (CURRENT_WS_NUM - 1) / GROUP_SIZE ))

# 4) decide next or prev
case "$1" in
  next) NEW_GROUP=$(( CURRENT_GROUP + 1 )) ;;
  prev) NEW_GROUP=$(( CURRENT_GROUP - 1 )) ;;
  *)
    echo "Usage: $0 next|prev"
    exit 1
    ;;
esac

# 5) compute the first workspace number of that new group
START_WS_NUM=$(( NEW_GROUP * GROUP_SIZE + 1 ))

# 6) bounds check
if (( START_WS_NUM < 1 )); then
    echo "Already at the first group."
    exit 1
elif (( START_WS_NUM > TOTAL_WORKSPACES )); then
    echo "No more workspaces beyond group $NEW_GROUP."
    exit 1
fi

# 7) build and send the swaymsg commands
for (( i = 0; i < GROUP_SIZE; i++ )); do
    ws_num=$(( START_WS_NUM + i ))
    # pad to two digits:
    ws_prefix=$(printf "ws%02d" "$ws_num")
    for mon in "${monitors[@]}"; do
        swaymsg workspace "${ws_prefix}-${mon}"
    done
done

# 8) (optional) focus a particular output if you want:
# swaymsg "focus output 'BNQ ZOWIE XL LCD EBF2R02370SL0'"

echo "Switched to group #$NEW_GROUP (workspaces ${START_WS_NUM}–$((START_WS_NUM+GROUP_SIZE-1)))."
