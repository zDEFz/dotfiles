#!/bin/bash
# Optimized network status script for i3blocks using mullvad status
# Configuration
GATEWAY="fritz.box"
INTERNET="194.242.2.2"  # Mullvad DNS
PING_TIMEOUT=5
CACHE_FILE="/tmp/mullvad_status_$(id -u)"
CACHE_DURATION=10

# Colors
COLOR_WARNING="#B58900"
COLOR_ERROR="#CB4B16"
COLOR_VPN_OK="#A1C3F3"
COLOR_VPN_DOWN="#D65A31"

# Fast ping function
fast_ping() {
    ping -c1 -W${PING_TIMEOUT} -q "$1" >/dev/null 2>&1
}

# Pango markup function
pango_color() {
    echo "<span color='$2'>$1</span>"
}

# Cleanup function
cleanup() {
    rm -f "$GATEWAY_TEMP" "$INTERNET_TEMP" 2>/dev/null
}
trap cleanup EXIT

# Use unique temp files
TEMP_SUFFIX="$(date +%s%N)_$$"
GATEWAY_TEMP="/tmp/gateway_${TEMP_SUFFIX}"
INTERNET_TEMP="/tmp/internet_${TEMP_SUFFIX}"

# Check gateway and internet in parallel
{
    fast_ping "$GATEWAY" && echo "gateway_ok" > "$GATEWAY_TEMP"
} &
{
    fast_ping "$INTERNET" && echo "internet_ok" > "$INTERNET_TEMP"
} &

wait

# Check results
GATEWAY_OK=false
INTERNET_OK=false
[[ -f "$GATEWAY_TEMP" ]] && GATEWAY_OK=true
[[ -f "$INTERNET_TEMP" ]] && INTERNET_OK=true

# Handle connection failures
if ! $GATEWAY_OK; then
    pango_color "Gateway down" "$COLOR_ERROR"
    exit 1
fi

if ! $INTERNET_OK; then
    pango_color "Gateway up, Internet down" "$COLOR_WARNING"
    exit 2
fi

# Check cached VPN status
if [[ -f "$CACHE_FILE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -lt $CACHE_DURATION ]]; then
    cat "$CACHE_FILE"
    exit 0
fi

# Get VPN status using mullvad command
MULLVAD_OUTPUT=$(mullvad status 2>/dev/null)

if [[ $? -ne 0 ]] || [[ -z "$MULLVAD_OUTPUT" ]]; then
    OUTPUT=$(pango_color "Internet up, VPN status unknown" "$COLOR_WARNING")
    echo "$OUTPUT" > "$CACHE_FILE" 2>/dev/null
    echo "$OUTPUT"
    exit 3
fi

# Parse mullvad status output
if echo "$MULLVAD_OUTPUT" | grep -q "^Connected"; then
    # Extract relay info (e.g., "de-fra-wg-003")
    RELAY=$(echo "$MULLVAD_OUTPUT" | grep "Relay:" | awk '{print $2}')
    OUTPUT=$(pango_color "Gateway up, Internet up, VPN: $RELAY" "$COLOR_VPN_OK")
else
    OUTPUT=$(pango_color "Gateway up, Internet up, VPN down" "$COLOR_VPN_DOWN")
fi

# Cache the result
echo "$OUTPUT" > "$CACHE_FILE" 2>/dev/null
echo "$OUTPUT"
exit 0
