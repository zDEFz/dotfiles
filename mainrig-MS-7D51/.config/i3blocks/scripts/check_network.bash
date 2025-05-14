#!/bin/bash

# Set variables for better maintenance and reuse
GATEWAY="fritz.box"
INTERNET="google.com"
PING_COUNT=1
PING_TIMEOUT=2

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
COLOR_SUCCESS="#F3A1A1"    # Muted gray-blue for normal status
COLOR_WARNING="#B58900"    # Subdued amber for warnings
COLOR_ERROR="#CB4B16"      # Muted orange-red for errors

# Use early returns for cleaner logic flow
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

# Both checks passed
pango_color "Gateway up, Internet up" "$COLOR_SUCCESS"
exit 0
