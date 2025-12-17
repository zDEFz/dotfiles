#!/bin/bash
STATUS_FILE="/tmp/mullvad_current_status"
RELAY_FILE="/tmp/mullvad_current_relay"

if ! pgrep -f "mullvad status listen" > /dev/null; then
    mullvad status | head -n 1 > "$STATUS_FILE"
    mullvad status | awk '/Relay:/ {print $2}' > "$RELAY_FILE" 2>/dev/null

    nohup bash -c "
    mullvad status listen | while read -r line; do
        if [[ \"\$line\" =~ ^(Connected|Disconnected|Connecting|Disconnecting)\$ ]]; then
            echo \"\$line\" > '$STATUS_FILE'
        elif echo \"\$line\" | grep -q 'Relay:'; then
            relay=\$(echo \"\$line\" | awk '{print \$2}')
            echo \"\$relay\" > '$RELAY_FILE'
        fi
    done" &>/dev/null &
fi

status=$(cat "$STATUS_FILE" 2>/dev/null || mullvad status | head -n 1)
relay=$(cat "$RELAY_FILE" 2>/dev/null)

if [[ "$status" == "Connected" && -n "$relay" ]]; then
    text="Connected: $relay"
else
    text="$status"
fi

case "$status" in
    Connected)      color="#1AAFEF" ;;  # blue
    Connecting)     color="#FFDF00" ;;  # warm yellow
    Disconnecting)  color="#FFDF00" ;;
    Disconnected)   color="#FF8A65" ;;  # warm orange/red
    *)              color="#93A1A1" ;;
esac

echo "<span foreground=\"$color\">$text</span>"
