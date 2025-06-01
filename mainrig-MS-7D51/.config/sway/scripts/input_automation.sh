#!/bin/bash
[ -z "$(pgrep -x dotoold)" ] && { dotoold; } # start dotoold if not running

CHOICE=$(echo -e "Type clipboard\nType vmpwd\nType date\nCancel" | wofi --dmenu --hide-scroll -Dlayer=overlay)

# Exit immediately if ESC or nothing selected
[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    "Type clipboard")
        echo "type $(wl-paste)" | dotoolc
        ;;
    "Type vmpwd")
        echo "type W50zyOgGmdY9DZbuvRHy" | dotoolc
        ;;
    "Type date")
        echo "type $(date --iso-8601)" | dotoolc
        ;;
    *)
        notify-send "No valid selection"
        ;;
esac
