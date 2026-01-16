#!/bin/bash

# menu: Typing Tools | Type clipboard
type_clipboard() {
    TEXT=$(wl-paste)
    [ -n "$TEXT" ] && printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
}

# menu: Typing Tools | Type date
type_date() { printf 'key leftctrl\ntype %s\n' "$(date --iso-8601)" | dotoolc; }

# menu: Typing Tools | Type hostname
type_hostname() { printf 'key leftctrl\ntype %s\n' "$(hostname)/" | dotoolc; }

# menu: Typing Tools | Type fritzbox
type_http_fritzbox() { printf 'key leftctrl\ntype %s\n' "http://fritz.box" | dotoolc; }

# menu: Typing Tools | Type http+hostname
type_http_hostname() { printf 'key leftctrl\ntype %s\n' "http://$(hostname)/" | dotoolc; }

# menu: Typing Tools | Type http+hostname+audio+search_all
type_http_hostname_audio_search_all() { printf 'key leftctrl\ntype %s\n' "http://$(hostname)/audio/search_all" | dotoolc; }

# menu: Typing Tools | Type http+hostname+shenzhen_solitaire+shenzhen_solitaire
type_http_hostname_shenzhen_solitaire() { printf 'key leftctrl\ntype %s\n' "http://$(hostname)/shenzhen_solitaire/" | dotoolc; }

# menu: Typing Tools | Type kvm
type_https_kvm() { printf 'key leftctrl\ntype %s\n' "https://kvm" | dotoolc; }

# menu: Typing Tools | Type local ip
type_local_ip() {
    TEXT=$(ip addr show | grep -i 'inet 192' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
    printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
}

# menu: Typing Tools | Type vmpwd
type_vmpwd() {
    [ -n "$vmpwd" ] && printf 'key leftctrl\ntype %s\nkey Tab\nkey space\nkey Tab\nkey space\n' "$vmpwd" | dotoolc
}

# menu: Typing Tools | Type veracrypt pwd
type_veracrypt_pwd() {
    [ -n "$veracryptpwd" ] && printf 'typedelay 20\nkeydelay 20\ntype %s\nkey Enter\nkey Enter\n' "$veracryptpwd" | dotoolc
}

# menu: Typing Tools | x0pipeclip
share_clipboard_text() {
    source /home/blu/scripts/functions/in_use/transfers/paste_services
    x0pipeclip "$(wl-paste)"
}

# menu: MyAnimeList | MAL Synopsis from clipboard
myanimelist_synopsis_clipboard() {
    "$USER_HOME"/.config/sway/scripts/myanimelist_coverart_search.sh "$(wl-paste)"
}