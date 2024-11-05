#!/bin/bash

# Path to your i3blocksreload.sh script
RELOAD_SCRIPT="/home/blu/git/mainrig-MS-7D51/.config/sway/i3blocksreload.sh"

# Keep track of the last day the script was run
LAST_RUN_DAY=""

while true; do
    # Get the current date in YYYY-MM-DD format
    CURRENT_DAY=$(date +%F)

    # Check if it's a new day
    if [[ "$CURRENT_DAY" != "$LAST_RUN_DAY" ]]; then
        # Run the reload script
        bash "$RELOAD_SCRIPT"
        
        # Update the last run day
        LAST_RUN_DAY="$CURRENT_DAY"
    fi

    # Wait 60 seconds before checking again
    sleep 60
done
