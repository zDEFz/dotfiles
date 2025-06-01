#!/bin/bash
# If 'dotoold' is not running, start it in the background with nohup (to ignore hangups) and discard all output
[[ -f /home/blu/.secure_env ]] && source /home/blu/.secure_env
! pgrep -x dotoold > /dev/null && nohup dotoold > /dev/null 2>&1 &

CHOICE=$(echo -e "Type clipboard\nType vmpwd\nType date\nCancel" | wofi --dmenu --hide-scroll -Dlayer=overlay)

RELEASE_CTRL() { echo "key leftctrl" | dotoolc;  } 
# Exit immediately if ESC or nothing selected
[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    "Type clipboard")
       { 
          RELEASE_CTRL
          echo type "$(wl-paste)"
       } | dotoolc
        ;;
    "Type vmpwd")
       { 
          RELEASE_CTRL
          echo "type ${vmpwd}";  
       }  | dotoolc       
        ;;
    "Type date")
    {
      RELEASE_CTRL
      echo "type $(date --iso-8601)"
    } | dotoolc
        ;;
    *)
        notify-send "No valid selection"
        ;;
esac
