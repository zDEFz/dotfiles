#!/bin/bash

TOGGLE_FILE=~/.toggle_state_speakers_headphone

# Check if the toggle file exists
if [ -e "$TOGGLE_FILE" ]; then
    # If it exists, read the state from it
    STATE=$(<"$TOGGLE_FILE")
else
    # If it doesn't exist, set the default state
    STATE="speakers"
fi

# Toggle the state
if [ "$STATE" == "speakers" ]; then
    NEW_STATE="headphones"
else
    NEW_STATE="speakers"
fi

# Save the new state to the toggle file
echo "$NEW_STATE" > "$TOGGLE_FILE"

# Source aliases
source ~/.aliases

# Change directory
cd ~/broadlink || exit

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Execute command based on the state
if [ "$NEW_STATE" == "speakers" ]; then
    control_dac toggle-speakers-headphone
    echo "out: 󰓃"
else
    control_dac toggle-speakers-headphone
    echo "out: "
fi
