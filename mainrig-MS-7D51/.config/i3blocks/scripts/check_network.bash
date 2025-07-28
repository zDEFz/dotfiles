#!/bin/bash
# Optimized network status script for i3blocks using Mullvad VPN status
# Configuration
GATEWAY="fritz.box"
INTERNET="194.242.2.2"  # Mullvad DNS
PING_TIMEOUT=5
CACHE_FILE="/tmp/mullvadstatus$(id -u)"
CACHE_DURATION=10
DEBUG_LOG="/tmp/mullvadstatus.log"
DEBUG_MODE=false  # Set to true to enable logging

# Colors (high-contrast for accessibility)
COLOR_WARNING="#FFB300"  # Amber for warnings
COLOR_ERROR="#D81B60"    # Red for errors
COLOR_VPN_OK="#4CAF50"   # Green for VPN connected
COLOR_VPN_DOWN="#F44336" # Red for VPN disconnected

# Fast ping function
fast_ping() {
    ping -c1 -W"${PING_TIMEOUT}" -q "$1" >/dev/null 2>&1
}

# Pango markup function
pango_color() {
    echo "<span color='$2'>$1</span>"
}

# Debug logging function
log_debug() {
    if [[ "$DEBUG_MODE" == true ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$DEBUG_LOG"
    fi
}

# Cleanup function
cleanup() {
    rm -f "$GATEWAY_TEMP" "$INTERNET_TEMP" 2>/dev/null
    log_debug "Cleaned up temp files"
}

# Trap signals for cleanup
trap cleanup EXIT INT TERM

# Input validation
if [[ -z "$GATEWAY" ]] || [[ -z "$INTERNET" ]]; then
    pango_color "Error: GATEWAY or INTERNET not set" "$COLOR_ERROR"
    log_debug "Configuration error: GATEWAY or INTERNET not set"
    exit 1
fi

# Use unique temp files
TEMPSUFFIX="$(date +%s%N)_$$"
GATEWAY_TEMP="/tmp/gateway_${TEMPSUFFIX}"
INTERNET_TEMP="/tmp/internet_${TEMPSUFFIX}"

# Check if temp directory is writable
if ! touch "$GATEWAY_TEMP" 2>/dev/null; then
    pango_color "Error: Cannot write to temp directory" "$COLOR_ERROR"
    log_debug "Cannot write to temp directory: $GATEWAY_TEMP"
    exit 1
fi
rm -f "$GATEWAY_TEMP" 2>/dev/null

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
    log_debug "Gateway ping failed: $GATEWAY"
    exit 1  # Exit code 1: Gateway down
fi

if ! $INTERNET_OK; then
    pango_color "Gateway up, Internet down" "$COLOR_WARNING"
    log_debug "Internet ping failed: $INTERNET"
    exit 2  # Exit code 2: Internet down
fi

# Check cached VPN status
if [[ -f "$CACHE_FILE" ]] && find "$CACHE_FILE" -mmin -"$((CACHE_DURATION / 60))" >/dev/null 2>&1; then
    cat "$CACHE_FILE"
    log_debug "Using cached VPN status"
    exit 0  # Exit code 0: Success (cached)
fi

# Get VPN status using mullvad command with timeout
MULLVAD_OUTPUT=$(timeout 3 mullvad status 2>/dev/null)
if [[ $? -ne 0 ]] || [[ -z "$MULLVAD_OUTPUT" ]]; then
    OUTPUT=$(pango_color "Internet up, VPN status unknown" "$COLOR_WARNING")
    echo "$OUTPUT" > "$CACHE_FILE" 2>/dev/null
    log_debug "Mullvad status check failed or empty"
    echo "$OUTPUT"
    exit 3  # Exit code 3: VPN status unknown
fi

# Parse mullvad status output
if echo "$MULLVAD_OUTPUT" | grep -q "^Connected"; then
    RELAY=$(echo "$MULLVAD_OUTPUT" | grep "Relay:" | awk '{print $2}' | head -1)
    OUTPUT=$(pango_color "Gateway up, Internet up, VPN: ${RELAY:-unknown}" "$COLOR_VPN_OK")
else
    OUTPUT=$(pango_color "Gateway up, Internet up, VPN down" "$COLOR_VPN_DOWN")
fi

# Cache the result
if ! echo "$OUTPUT" > "$CACHE_FILE" 2>/dev/null; then
    log_debug "Failed to write cache file: $CACHE_FILE"
fi
echo "$OUTPUT"
log_debug "VPN status: $OUTPUT"
exit 0  # Exit code 0: Success
