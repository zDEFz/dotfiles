#!/bin/bash
# If 'dotoold' is not running, start it in the background with nohup (to ignore hangups) and discard all output
! pgrep -x dotoold > /dev/null && nohup dotoold > /dev/null 2>&1 &

CHOICE=$(echo -e "Type clipboard\nType vmpwd\nType date\nCancel" | wofi --dmenu --hide-scroll -Dlayer=overlay)

DEBOUNCE_CTRL() { echo "key leftctrl" | dotoolc;  } 
# Exit immediately if ESC or nothing selected
[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    "Type clipboard")
        {
          DEBOUNCE_CTRL
          sleep 0.25
          echo -n type wl-paste
        }  | dotoolc
        ;;
    "Type vmpwd")
       { 
          DEBOUNCE_CTRL
          echo "type W50zyOgGmdY9DZbuvRHy";  
       }  | dotoolc       
        ;;
    "Type date")
    {
      DEBOUNCE_CTRL
      echo "type $(date --iso-8601)"
    } | dotoolc
        ;;
    *)
        notify-send "No valid selection"
        ;;
esac
