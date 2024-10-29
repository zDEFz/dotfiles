#!/bin/bash
TOGGLE_FILE=~/.toggle_state_adi2-input

# Check if the toggle file exists
if [ -e "$TOGGLE_FILE" ]; then
    # If it exists, read the state from it
    STATE=$(<"$TOGGLE_FILE")
else
    # If it doesn't exist, set the default state
    STATE="opt"
fi

# Toggle the state
if [ "$STATE" == "opt" ]; then
    NEW_STATE="usb"
else
    NEW_STATE="opt"
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
if [ "$NEW_STATE" == "opt" ]; then
    control_dac input-coax
    echo "in: 󱒄"
else
    control_dac input-usb
    echo "in: "
fi
