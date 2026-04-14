#!/bin/bash

# menu: MyAnimeList | 📺 MAL Synopsis from clipboard
app_mal_synopsis_clip() {
    "$USER_HOME"/.config/sway/scripts/myanimelist_coverart_search.sh "$(wl-paste)"
}


# Only run dispatcher if executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
