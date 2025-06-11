#!/bin/bash

case "$1" in
    next)
    echo '{ "command": ["playlist_next"] }' | socat - /tmp/mpvsockets/$(cat /tmp/wayland_app_id.txt)
      playerctl next
        ;;
    prev)
    echo '{ "command": ["playlist_prev"] }' | socat - /tmp/mpvsockets/$(cat /tmp/wayland_app_id.txt)
      playerctl previous
        ;;
    stop)
      playerctl stop
        ;;
    status)
      playerctl status
        ;;
    metadata)
      playerctl metadata
        ;;
    volume)
      if [ -z "$2" ]; then
        playerctl volume
      else
        playerctl volume "$2"
      fi
        ;;
    shuffle)
      playerctl shuffle
        ;;
    *)
      echo "Invalid command. Available commands: next, play-pause, prev, stop, status, metadata, volume, shuffle"
        ;;
esac
