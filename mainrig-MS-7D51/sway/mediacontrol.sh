#!/bin/bash
MPV_SOCKET="/tmp/mpvsocket"

case "$1" in
    mpv-next)
      echo playlist-next | socat - "$MPV_SOCKET"
        ;;
    mpv-pause)
      echo cycle pause | socat - "$MPV_SOCKET"
        ;;
    mpv-prev)
      echo playlist-prev | socat - "$MPV_SOCKET"
        ;;
    mpv-stop)
      echo quit | socat - "$MPV_SOCKET"
        ;;
    playerctl-next)
      playerctl next
        ;;
    playerctl-play-pause)
      playerctl play-pause
        ;;
    playerctl-prev)
      playerctl previous
        ;;
    playerctl-stop)
      playerctl stop
        ;;
    *)
      echo "Invalid command"
        ;;
esac
