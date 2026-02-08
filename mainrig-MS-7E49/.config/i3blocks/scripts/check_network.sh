#!/bin/bash
# check_network.sh - Monitor Mullvad VPN connection status and current relay with caching for efficiency

STATUS_CACHE="/tmp/mullvad_current_status"
RELAY_CACHE="/tmp/mullvad_current_relay"
WATCHER_NAME="mullvad-status-watcher"

# Start watcher if missing
pgrep -f "$WATCHER_NAME" > /dev/null || {
    ( exec -a "$WATCHER_NAME" bash -c '
        mullvad status listen | while read -r line; do
            case "$line" in
                Connected|Disconnected|Connecting|Disconnecting) echo "$line" > "'$STATUS_CACHE'" ;;
                *"Relay:"*) r="${line##*Relay: }"; echo "${r%% *}" > "'$RELAY_CACHE'" ;;
            esac
        done' ) &>/dev/null &
}

# Use redirection instead of cat for zero-fork reading
status=$(<"$STATUS_CACHE")
relay=$(<"$RELAY_CACHE")

[[ -z "$status" ]] && status="Unknown"
text="$status"
[[ "$status" == "Connected" && -n "$relay" ]] && text="Connected: $relay"

case "$status" in
    Connected)     color="#1AAFEF" ;;
    Connect*)      color="#FFDF00" ;;
    Disconnected)  color="#FF8A65" ;;
    *)             color="#93A1A1" ;;
esac

echo "<span foreground=\"$color\">$text</span>"