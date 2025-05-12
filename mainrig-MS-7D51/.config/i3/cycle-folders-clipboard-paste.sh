#!/bin/bash

# Directory to cycle through its subfolders
DIRECTORY="/sshfsmounts/20tb-2-raid1c3/video/anime/anime-shows/"
# Temporary file to keep track of the current index
INDEX_FILE="/tmp/sshfsmounts_cycle_folder_index.txt"

# Create an array of all subdirectories
cd "$DIRECTORY"
IFS=$'\n' read -d '' -r -a folders < <(find . -maxdepth 1 -type d | sed '1d;s|./||' | sort)

# Read the current index, if the file doesn't exist, start with 0
if [ ! -f "$INDEX_FILE" ]; then
    echo "0" > "$INDEX_FILE"
    index=0
else
    index=$(cat "$INDEX_FILE")
fi

# Get folder name and update clipboard
folder=${folders[$index]}
echo "$folder" | xclip -selection clipboard

# Simulate a brief pause to ensure the selection action completes
sleep 0.5

# Use xdotool to type the content of the clipboard
xdotool type "$(xclip -o -selection clipboard)"

# Update index for next run, wrap if necessary
if [ $((index + 1)) -ge ${#folders[@]} ]; then
    index=0
else
    index=$((index + 1))
fi

# Save the new index
echo "$index" > "$INDEX_FILE"
