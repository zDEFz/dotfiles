#!/bin/bash

# --- CATEGORY: HELPERS ---
# Internal helper used for moving containers to specific outputs
_open_local_service() {
    # Use a unique variable name to avoid system $PATH collision
    local _target="$1"
    local _proto="${2:-https}" 
    
    # Construct the URL carefully
    _firefox_open_url "${_proto}://$(hostname)/${_target}"
}

_firefox_open_url() {
    firefox --no-remote -P "firefox-default" --class "firefox-default" --name "firefox-default" "$1"
}

_chromium_open_url() {
	 chromium --app="$1"
}

_chrome_open_url() { 
	chrome --app="$1"
}

_rdp_connect() {
    local host="$1"
    local user="$2"
    local pass="$3"

    echo "Connecting to $host..."
	
    wlfreerdp \
        /u:"$user" \
        /p:"$pass" \
        /v:"$host" \
        /cert:ignore \
        +clipboard \
        /dynamic-resolution \
		/drive:home_tmp,"$HOME/tmp"
        # unless you want to share your home drive with remote
		# /drive:home,"$HOME"
}

_win_move_to_output() { 
    swaymsg move container to output "'${!1}'"
}

