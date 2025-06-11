#!/bin/bash
# Optimized network status script for i3blocks
# Key optimizations: faster ping, parallel checks, cached VPN status

# Configuration
GATEWAY="fritz.box"
INTERNET="8.8.8.8"  # Using IP instead of hostname for faster resolution
PING_TIMEOUT=1      # Reduced from 2 seconds
MULLVAD_API_URL="https://am.i.mullvad.net/json"
CACHE_FILE="/tmp/mullvad_status_$$"  # Per-process cache file
CACHE_DURATION=10   # Cache VPN status for 10 seconds

# Colors
COLOR_WARNING="#B58900"
COLOR_ERROR="#CB4B16"
COLOR_VPN_OK="#A1C3F3"
COLOR_VPN_DOWN="#D65A31"

# Fast ping function with minimal output
fast_ping() {
    ping -c1 -W${PING_TIMEOUT} -q "$1" >/dev/null 2>&1
}

# Pango markup function
pango_color() {
    echo "<span color='$2'>$1</span>"
}

# Check gateway and internet in parallel
{
    fast_ping "$GATEWAY" && echo "gateway_ok" > /tmp/gateway_$$
} &
{
    fast_ping "$INTERNET" && echo "internet_ok" > /tmp/internet_$$
} &

# Wait for both ping checks to complete
wait

# Check results
GATEWAY_OK=false
INTERNET_OK=false

[[ -f /tmp/gateway_$$ ]] && GATEWAY_OK=true && rm -f /tmp/gateway_$$
[[ -f /tmp/internet_$$ ]] && INTERNET_OK=true && rm -f /tmp/internet_$$

# Handle connection failures early
if ! $GATEWAY_OK; then
    pango_color "Gateway down" "$COLOR_ERROR"
    exit 1
fi

if ! $INTERNET_OK; then
    pango_color "Gateway up, Internet down" "$COLOR_WARNING"
    exit 2
fi

# Check cached VPN status first
if [[ -f "$CACHE_FILE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -lt $CACHE_DURATION ]]; then
    # Use cached result
    cat "$CACHE_FILE"
    exit 0
fi

# Fetch fresh VPN status with timeout
MULLVAD_JSON=$(timeout 3 curl -s --connect-timeout 2 --max-time 3 "$MULLVAD_API_URL" 2>/dev/null)

if [[ -z "$MULLVAD_JSON" ]]; then
    OUTPUT=$(pango_color "Internet up, VPN status unknown" "$COLOR_WARNING")
    echo "$OUTPUT" > "$CACHE_FILE" 2>/dev/null
    echo "$OUTPUT"
    exit 3
fi

# Parse VPN status
MULLVAD_CONN=$(echo "$MULLVAD_JSON" | jq -r '.mullvad_exit_ip // false' 2>/dev/null)

if [[ "$MULLVAD_CONN" == "true" ]]; then
    MULLVAD_HOST=$(echo "$MULLVAD_JSON" | jq -r '.mullvad_exit_ip_hostname // "Unknown"' 2>/dev/null)
    OUTPUT=$(pango_color "Gateway up, Internet up, VPN: $MULLVAD_HOST" "$COLOR_VPN_OK")
else
    OUTPUT=$(pango_color "Gateway up, Internet up, VPN down" "$COLOR_VPN_DOWN")
fi

# Cache the result
echo "$OUTPUT" > "$CACHE_FILE" 2>/dev/null
echo "$OUTPUT"
exit 0
