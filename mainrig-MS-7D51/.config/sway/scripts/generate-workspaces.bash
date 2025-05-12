#!/bin/bash

# ——— configure your active monitors here ———
# Order matters: these names must match your i3 outputs ($LL, $L, etc.)
monitors=(LL L M R RR MON_KB)

num_mon=${#monitors[@]}

# Function to generate one workspace’s commands
generate_workspace() {
    local ws_name="$1"
    local base="$2"

    for idx in "${!monitors[@]}"; do
        local m="${monitors[$idx]}"
        local val=$(( base + idx ))
        echo "set \$${ws_name}-${m} \"$val\""
        echo -e "\tworkspace \$${ws_name}-${m} output \$${m}"
    done
}

# Loop through workspaces 01..13
for i in {1..13}; do
    ws=$(printf "ws%02d" "$i")
    # Calculate the starting number for this workspace
    base=$(( (i - 1) * num_mon + 1 ))
    generate_workspace "$ws" "$base"
done
