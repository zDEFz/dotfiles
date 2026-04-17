#!/usr/bin/env bash

# Fetch windows and format for Wofi (ID: Title\0icon\x1fAppID)
list=$(niri msg -j windows | jq -r '.[] | "\(.id): \(.title // .app_id)\u0000icon\u001f\(.app_id)"')

# Launch Wofi and extract ID
selection=$(printf "$list" | wofi -d -I -i --allow-images | cut -d':' -f1)

# Focus window if selection exists
[[ -n "$selection" ]] && niri msg action focus-window --id "$selection"
