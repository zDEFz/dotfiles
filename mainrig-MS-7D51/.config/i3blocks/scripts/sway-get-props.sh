#!/bin/sh
# Subscribe to window focus events and process with jq more efficiently
swaymsg -t subscribe '["window"]' | 
  jq --unbuffered -r '
    # Process only focus events to reduce computation
    select(.change == "focus") | 
    # Build string directly instead of concatenating
    "Type: \(.container.type // ""), App ID: \(.container.app_id // ""), Name: \(.container.name // ""), Shell: \(.container.shell // ""), Con_ID: \(.container.id // "")"
  '
