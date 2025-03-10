#!/bin/bash

# Check if dotoold is running
if ! pgrep -x "dotoold" > /dev/null; then
    dotoold &
    sleep 0.1  # Give it some time to start if necessary
fi

# Perform triple left-click using dotoolc
for i in 1 2 3; do
    echo click left
    sleep 0.05
done | dotoolc
