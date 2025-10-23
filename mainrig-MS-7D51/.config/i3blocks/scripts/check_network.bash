#!/bin/bash
STATUS_FILE="/tmp/mullvad_current_status"
RELAY_FILE="/tmp/mullvad_current_relay"

# If no background listener, start one and get initial status
if ! pgrep -f "mullvad status listen" > /dev/null; then
    # Get initial status
    mullvad status | head -n 1 > "$STATUS_FILE"
    mullvad status | awk '/Relay:/ {print $2}' > "$RELAY_FILE" 2>/dev/null
    
    # Start background listener (without debug output)
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

# Read and output current status
status=$(cat "$STATUS_FILE" 2>/dev/null || mullvad status | head -n 1)
relay=$(cat "$RELAY_FILE" 2>/dev/null)

if [[ "$status" == "Connected" && -n "$relay" ]]; then
    echo "$status: $relay"
else
    echo "$status"
fi
