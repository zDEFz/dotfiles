#!/bin/bash

case "$1" in
    pause)
        echo cycle pause | socat - /tmp/mpvsocket
        #playerctl pause
        ;;
    next)
        echo playlist-next | socat - /tmp/mpvsocket
#       playerctl next
        ;;
    prev)
        echo playlist-prev | socat - /tmp/mpvsocket
 #      playerctl previous
        ;;
    stop)
        echo quit | socat - /tmp/mpvsocket
  #     playerctl stop
        ;;
    *)
        echo "Invalid command"
        ;;
esac
