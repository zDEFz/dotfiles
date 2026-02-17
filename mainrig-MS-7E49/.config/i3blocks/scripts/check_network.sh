#!/bin/bash
# check_network.sh - Mullvad monitor with RAM caching

CACHE_FILE="/dev/shm/mullvad_cache"
WATCHER_NAME="mullvad-status-watcher"

# Start watcher if missing
if ! pgrep -f "$WATCHER_NAME" > /dev/null; then
    ( exec -a "$WATCHER_NAME" bash -c '
        mullvad status listen | while read -r line; do
            clean_line=$(echo "$line" | xargs)
            case "$clean_line" in
                Connected|Disconnected|Connecting|Disconnecting)
                    # Store both status and relay in one atomic write
                    if [[ "$clean_line" == "Connected" ]]; then
                        relay=$(mullvad status | grep -Ei "Relay:" | awk "{print \$2}")
                        echo "$clean_line|$relay" > "'$CACHE_FILE'"
                    else
                        echo "$clean_line|" > "'$CACHE_FILE'"
                    fi
                    ;;
                Relay:*)
                    # Update relay while preserving status
                    if [[ -f "'$CACHE_FILE'" ]]; then
                        status=$(cut -d"|" -f1 < "'$CACHE_FILE'" 2>/dev/null)
                        relay=$(echo "$clean_line" | awk "{print \$2}")
                        echo "${status:-Connected}|$relay" > "'$CACHE_FILE'"
                    fi
                    ;;
            esac
        done' ) &>/dev/null &
fi

# Read cache (single file with pipe delimiter: status|relay)
if [[ -f "$CACHE_FILE" ]]; then
    IFS='|' read -r status relay < "$CACHE_FILE"
fi

# Force immediate update only if cache is completely missing
if [[ -z "$status" ]]; then
    m_out=$(mullvad status)
    status=$(echo "$m_out" | grep -Ei "^(Connected|Disconnected|Connecting|Disconnecting)" | head -n1)
    relay=$(echo "$m_out" | grep -Ei "Relay:" | awk '{print $2}')
    echo "${status:-Unknown}|${relay}" > "$CACHE_FILE"
fi

# Build display text
if [[ "$status" == "Connected" && -n "$relay" ]]; then
    text="Connected to $relay"
elif [[ "$status" == "Connected" ]]; then
    text="Connected"
else
    text="${status:-Unknown}"
fi

# Color selection
case "$status" in
    Connected)    color="#1AAFEF" ;;
    Connect*)     color="#FFDF00" ;;
    Disconnected) color="#FF8A65" ;;
    *)            color="#93A1A1" ;;
esac

# Output
echo "<span foreground=\"$color\">$text</span>"
