#!/bin/bash

FILE="/tmp/wayland_app_id.txt"

# Read the app_id directly when the key is pressed
if [[ -f "$FILE" ]]; then
  app_id=$(<"$FILE")
  if [[ -n "$app_id" ]]; then
    # Focus the window and send it fullscreen
    swaymsg "[app_id=\"$app_id\"] focus"
    swaymsg "[app_id=\"$app_id\"] fullscreen enable"
  fi
fi
