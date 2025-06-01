#!/bin/bash

# Set variables for better maintenance and reuse
GATEWAY="fritz.box"
INTERNET="google.com"
PING_COUNT=1
PING_TIMEOUT=2
MULLVAD_API_URL="https://am.i.mullvad.net/json"

# Use function for ping test to avoid code duplication
check_host() {
    ping -c $PING_COUNT -W $PING_TIMEOUT "$1" &>/dev/null
    return $?
}

# Pango markup function for colored output
pango_color() {
    local text="$1"
    local color="$2"
    echo "<span color='$color'>$text</span>"
}

# More subdued colors that match your i3blocks theme
COLOR_WARNING="#B58900"    # Subdued amber for warnings
COLOR_ERROR="#CB4B16"      # Muted orange-red for errors
COLOR_VPN_OK="#A1C3F3"     # Soft blue for VPN connected
COLOR_VPN_DOWN="#D65A31"   # Soft red for VPN disconnected

# Check gateway first
if ! check_host "$GATEWAY"; then
    pango_color "Gateway down" "$COLOR_ERROR"
    exit 1
fi

# Gateway is up, now check internet
if ! check_host "$INTERNET"; then
    pango_color "Gateway up, Internet down" "$COLOR_WARNING"
    exit 2
fi

# Both gateway and internet are up, now check Mullvad VPN status
MULLVAD_JSON=$(curl -s "$MULLVAD_API_URL")
if [ -z "$MULLVAD_JSON" ]; then
    # If the API failed to respond, treat as warning
    pango_color "Internet up, VPN status unknown" "$COLOR_WARNING"
    exit 3
fi

# Parse the "mullvad_exit_ip" boolean (true if connected, false otherwise)
MULLVAD_CONN=$(echo "$MULLVAD_JSON" | jq -r '.mullvad_exit_ip')

if [ "$MULLVAD_CONN" = "true" ]; then
    # Extract server hostname only (omit IP)
    MULLVAD_HOST=$(echo "$MULLVAD_JSON" | jq -r '.mullvad_exit_ip_hostname')
    pango_color "Gateway up, Internet up, VPN: $MULLVAD_HOST" "$COLOR_VPN_OK"
    exit 0
else
    pango_color "Gateway up, Internet up, VPN down" "$COLOR_VPN_DOWN"
    exit 4
fi
