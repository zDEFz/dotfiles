#!/bin/bash

# menu: Typing Tools | Type clipboard
type_clip() {
    local text=$(wl-paste)
    [ -n "$text" ] && printf 'key leftctrl\ntype %s\n' "$text" | dotoolc
}

# menu: Typing Tools | Type date
t_date() { printf 'key leftctrl\ntype %s\n' "$(date --iso-8601)" | dotoolc; }

# menu: Typing Tools | Type hostname
t_host() { printf 'key leftctrl\ntype %s\n' "$(hostname)/" | dotoolc; }

# menu: Typing Tools | Type http+hostname
t_http_host() { printf 'key leftctrl\ntype %s\n' "http://$(hostname)/" | dotoolc; }

# menu: Typing Tools | Type http+hostname+audio+search_all
t_http_audio() { printf 'key leftctrl\ntype %s\n' "http://$(hostname)/audio/search_all" | dotoolc; }

# menu: Typing Tools | Type local ip
t_ip() {
    local ip=$(ip addr show | grep -i 'inet 192' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
    printf 'key leftctrl\ntype %s\n' "$ip" | dotoolc
}

# menu: Typing Tools | Type vmpwd
t_vmpwd() { [ -n "$vmpwd" ] && printf 'key leftctrl\ntype %s\nkey Tab\nkey space\nkey Tab\nkey space\n' "$vmpwd" | dotoolc; }

# menu: Typing Tools | Type veracrypt pwd
t_vera() { [ -n "$veracryptpwd" ] && printf 'typedelay 20\nkeydelay 20\ntype %s\nkey Enter\nkey Enter\n' "$veracryptpwd" | dotoolc; }

# menu: Typing Tools | x0pipeclip
share_clip() { source /home/blu/scripts/functions/in_use/transfers/paste_services; x0pipeclip "$(wl-paste)"; }

# menu: MyAnimeList | MAL Synopsis from clipboard
mal_syn() { "$USER_HOME"/.config/sway/scripts/myanimelist_coverart_search.sh "$(wl-paste)"; }