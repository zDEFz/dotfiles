#!/bin/bash
# check_network.sh - Mullvad monitor with RAM caching

STATUS_CACHE="/dev/shm/mullvad_current_status"
RELAY_CACHE="/dev/shm/mullvad_current_relay"
WATCHER_NAME="mullvad-status-watcher"

# Start watcher if missing
pgrep -f "$WATCHER_NAME" > /dev/null || {
    ( exec -a "$WATCHER_NAME" bash -c '
        mullvad status listen | while read -r line; do
            # Trim leading whitespace for comparison
            clean_line=$(echo "$line" | xargs)
            case "$clean_line" in
                Connected|Disconnected|Connecting|Disconnecting) 
                    echo "$clean_line" > "'$STATUS_CACHE'" ;;
                Relay:*) 
                    # Extract the relay name after the colon
                    echo "$clean_line" | awk "{print \$2}" > "'$RELAY_CACHE'" ;;
            esac
        done' ) &>/dev/null &
}

# 1. Read existing cache
status=$(<"$STATUS_CACHE" 2>/dev/null)
relay=$(<"$RELAY_CACHE" 2>/dev/null)

# 2. Force immediate update if cache is missing or relay is empty while connected
if [[ -z "$status" || ( "$status" == "Connected" && -z "$relay" ) ]]; then
    m_out=$(mullvad status)
    status=$(echo "$m_out" | grep -Ei "^(Connected|Disconnected|Connecting|Disconnecting)" | head -n1)
    relay=$(echo "$m_out" | grep -Ei "Relay:" | awk '{print $2}')
    
    echo "${status:-Unknown}" > "$STATUS_CACHE"
    [[ -n "$relay" ]] && echo "$relay" > "$RELAY_CACHE"
fi

# 3. Build the text string
if [[ "$status" == "Connected" && -n "$relay" ]]; then
    text="Connected to $relay"
elif [[ "$status" == "Connected" ]]; then
    text="Connected"
else
    text="${status:-Unknown}"
fi

# 4. Color selection
case "$status" in
    Connected)    color="#1AAFEF" ;;
    Connect*)     color="#FFDF00" ;;
    Disconnected) color="#FF8A65" ;;
    *)            color="#93A1A1" ;;
esac

# 5. Final Output
echo "<span foreground=\"$color\">$text</span>"
