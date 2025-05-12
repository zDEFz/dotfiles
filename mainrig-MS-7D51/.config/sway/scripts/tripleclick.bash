#!/bin/bash

# Ensure dotoold is running
if ! pgrep -x "dotoold" > /dev/null; then
    echo "Starting dotoold..."
    if ! dotoold &; then
        echo "Error: Failed to start dotoold." >&2
        exit 1
    fi
    sleep 0.1  # Allow time for dotoold to initialize
fi

# Ensure dotoolc is available
if ! command -v dotoolc &> /dev/null; then
    echo "Error: dotoolc command not found. Please ensure dotool is installed." >&2
    exit 1
fi

# Perform triple left-click using dotoolc
for i in {1..3}; do
    echo click left
    sleep 0.05  # Small delay between clicks
done | dotoolc