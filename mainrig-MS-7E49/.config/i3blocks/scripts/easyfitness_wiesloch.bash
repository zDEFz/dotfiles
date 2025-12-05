#!/bin/bash

# Check if Mullvad VPN is connected
if mullvad status | grep -q "Connected"; then
    # Get current day of the week (1=Monday, 7=Sunday)
    DAY=$(date +%u)
    # Get current hour as a decimal (no octal issues)
    HOUR=$((10#$(date +%H)))

    # Debug: show day and hour
    # echo "DAY=$DAY, HOUR=$HOUR"

    # Define business hours
    if [[ "$DAY" -ge 1 && "$DAY" -le 5 && "$HOUR" -ge 6 && "$HOUR" -lt 23 ]] || \
       [[ "$DAY" -eq 6 && "$HOUR" -ge 8 && "$HOUR" -lt 21 ]] || \
       [[ "$DAY" -eq 7 && "$HOUR" -ge 8 && "$HOUR" -lt 21 ]]; then
        # Inside business hours, run curl
        curl -s https://easyfitness.club/studio/easyfitness-wiesloch/ \
            | sed -n 's/.*class="meterbubble">\([0-9][0-9]*\)%.*/\1/p' \
            | head -n1 \
            | sed 's/$/% Gym/'
    else
        echo "Outside business hours, skipping command."
    fi
else
    echo "Not connected to Mullvad, skipping command."
fi
