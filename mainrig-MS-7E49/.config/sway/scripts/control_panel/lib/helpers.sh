#!/bin/bash

# --- CATEGORY: HELPERS ---
# Internal helper used for moving containers to specific outputs
_win_move_to_output() { 
    swaymsg move container to output "'${!1}'"
}

# Internal helper used for opening URLs in Firefox with specific profile and class
_firefox_open_url() {
    firefox --no-remote -P "firefox-default" --class "firefox-default" --name "firefox-default" "$1"
}

