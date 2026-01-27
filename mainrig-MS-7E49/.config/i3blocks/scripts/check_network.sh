#!/bin/bash

STATUS_CACHE="/tmp/mullvad_current_status"
RELAY_CACHE="/tmp/mullvad_current_relay"
WATCHER_NAME="mullvad-status-watcher"

if ! pgrep -f "$WATCHER_NAME" > /dev/null; then
    mullvad status | head -n 1 > "$STATUS_CACHE"
    mullvad status | awk '/Relay:/ {print $2}' > "$RELAY_CACHE" 2>/dev/null

    (
        exec -a "$WATCHER_NAME" bash -c '
            mullvad status listen | while read -r line; do
                if [[ "$line" =~ ^(Connected|Disconnected|Connecting|Disconnecting)$ ]]; then
                    echo "$line" > "'$STATUS_CACHE'"
                elif [[ "$line" == *"Relay:"* ]]; then
                    relay=$(echo "$line" | awk "{print \$2}")
                    echo "$relay" > "'$RELAY_CACHE'"
                fi
            done'
    ) &>/dev/null &
fi

status=$(cat "$STATUS_CACHE" 2>/dev/null)
relay=$(cat "$RELAY_CACHE" 2>/dev/null)

[[ -z "$status" ]] && status=$(mullvad status | head -n 1)

if [[ "$status" == "Connected" && -n "$relay" ]]; then
    text="Connected: $relay"
else
    text="$status"
fi

case "$status" in
    Connected)      color="#1AAFEF" ;;
    Connecting)     color="#FFDF00" ;;
    Disconnecting)  color="#FFDF00" ;;
    Disconnected)   color="#FF8A65" ;;
    *)              color="#93A1A1" ;;
esac

echo "<span foreground=\"$color\">$text</span>"
