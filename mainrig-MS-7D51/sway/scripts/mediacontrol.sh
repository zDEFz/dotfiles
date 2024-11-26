#!/bin/bash
MPV_SOCKET="/tmp/mpvsocket"

# Function to handle errors with mpv and fallback to playerctl
handle_mpv_error() {
  if ! socat - "$MPV_SOCKET" <<< "ping" &>/dev/null; then
    echo "MPV error or socket unavailable, switching to playerctl."
    playerctl "$@"
  else
    socat - "$MPV_SOCKET" <<< "$1"
  fi
}

case "$1" in
    mpv-next)
      handle_mpv_error "playlist-next"
        ;;
    mpv-pause)
      handle_mpv_error "cycle pause"
        ;;
    mpv-prev)
      handle_mpv_error "playlist-prev"
        ;;
    mpv-stop)
      handle_mpv_error "quit"
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
