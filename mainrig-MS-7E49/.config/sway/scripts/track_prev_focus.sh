#!/bin/sh
prev_focus=$(swaymsg -t get_seats -r | jq -r '.[0].focus')

exec 2>/dev/null

swaymsg -t subscribe -m '["window"]' | \
  jq --unbuffered -r 'select(.change == "focus") | .container.id' | \
  while IFS= read -r new_focus; do
    if [ "$new_focus" != "$prev_focus" ] && [ -n "$prev_focus" ]; then
      swaymsg "[con_id=$prev_focus] mark --add _prev"
    fi
    prev_focus=$new_focus
  done
