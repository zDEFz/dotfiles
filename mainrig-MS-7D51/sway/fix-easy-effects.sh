#!/bin/bash

# Count the number of 'aplay' processes
process_count=$(pgrep -fc "aplay -r 48000 -f S24_3LE /dev/zero")

if [ "$process_count" -eq 0 ]; then
    # If no instance is running, start it
    aplay -r 48000 -f S24_3LE /dev/zero &
    echo "Started the command."
elif [ "$process_count" -eq 1 ]; then
    # If exactly one instance is running, do nothing
    echo "The command is already running."
else
    # If more than one instance is running, kill all and restart
    pkill -f "aplay -r 48000 -f S24_3LE /dev/zero"
    aplay -r 48000 -f S24_3LE /dev/zero &
    echo "Killed extra instances and restarted the command."
fi
