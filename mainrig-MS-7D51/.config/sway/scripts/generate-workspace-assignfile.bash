#!/bin/bash

# Define the workspace range
start_num=1
end_num=13

# List your active outputs here (in display order)
monitors=(LL L M R RR MON_KB)
# monitors=(LL L M R RR TAIKO MON_KB)  # ← add/comment to include TAIKO

# Initialize the counter
counter=1

# Loop through each workspace index
for (( i = start_num; i <= end_num; i++ )); do
    ws=$(printf "ws%02d" "$i")
    # Loop through each monitor
    for m in "${monitors[@]}"; do
        echo "### ${ws}-${m} (${counter})"
        echo -e "\t"
        ((counter++))
    done
done
