#!/bin/bash

# menu: MyAnimeList | 📺 MAL Synopsis from clipboard
app_mal_synopsis_clip() {
    "$USER_HOME"/.config/sway/scripts/myanimelist_coverart_search.sh "$(wl-paste)"
}


"$@"
