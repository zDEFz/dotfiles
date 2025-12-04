#!/bin/bash

# Check if Mullvad VPN is connected using mullvad status
if mullvad status | grep -q "Connected"; then
    # Get the current day of the week (0=Sunday, 1=Monday, ..., 6=Saturday)
    DAY=$(date +%u)
    # Get the current hour (24-hour format)
    HOUR=$(date +%H)

    # Define the opening hours
    if [[ "$DAY" -ge 1 && "$DAY" -le 5 && "$HOUR" -ge 6 && "$HOUR" -lt 23 ]] || \
       [[ "$DAY" -eq 6 && "$HOUR" -ge 8 && "$HOUR" -lt 21 ]] || \
       [[ "$DAY" -eq 7 && "$HOUR" -ge 8 && "$HOUR" -lt 21 ]]; then
        # If within business hours and connected to Mullvad, run the curl command
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
