#!/bin/bash

# Define MIDI messages for each source
SOURCE_OPTICAL="F0 00 20 0d 71 02 18 20 02 F7"
SOURCE_USB="F0 00 20 0d 71 02 18 20 03 F7"

# Define state file to remember last selection
STATE_FILE="$HOME/.source_selection_state"

# Get current state or default to OPTICAL
if [ ! -f "$STATE_FILE" ]; then
    echo "OPTICAL" > "$STATE_FILE"
fi
CURRENT_SOURCE=$(cat "$STATE_FILE")

# Determine new source based on input
if [[ "$1" == "up" ]]; then
    case "$CURRENT_SOURCE" in
        "OPTICAL") NEW_SOURCE="USB" ;;
        "USB") NEW_SOURCE="OPTICAL" ;;
    esac
elif [[ "$1" == "down" ]]; then
    case "$CURRENT_SOURCE" in
        "OPTICAL") NEW_SOURCE="USB" ;;
        "USB") NEW_SOURCE="OPTICAL" ;;
    esac
else
    echo "Usage: $0 [up|down]"
    exit 1
fi

# Get the MIDI device
MIDI_DEVICE=$(amidi -l | awk '/ADI-2 DAC/ {print $2}')

# Check if MIDI device is busy
if ! amidi -p "$MIDI_DEVICE" -S "$SOURCE_OPTICAL" 2>/dev/null; then
    notify-send "MIDI Device Error" "Cannot open MIDI device $MIDI_DEVICE. Device might be busy."
    exit 1
fi

# Send MIDI command based on new source
case "$NEW_SOURCE" in
    "OPTICAL") amidi -p "$MIDI_DEVICE" -S "$SOURCE_OPTICAL" ;;
    "USB") amidi -p "$MIDI_DEVICE" -S "$SOURCE_USB" ;;
esac

# Save new state
echo "$NEW_SOURCE" > "$STATE_FILE"

# Notify user with mako
notify-send "Source Changed" "Switched to $NEW_SOURCE"
