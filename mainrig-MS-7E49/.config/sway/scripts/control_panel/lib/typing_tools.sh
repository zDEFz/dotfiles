#!/bin/bash

# --- CATEGORY: TYPING TOOLS ---
# menu: Typing Tools | 📱 Type Phone plain
type_phone_plain() {
    TEXT=$(echo "$PERSONAL_PHONE" | sed 's/[^+0-9]//g')
    [ -n "$TEXT" ] && printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
}

# menu: Typing Tools | 📱 Type Phone plain without country code
type_phone_no_country() {
    TEXT=$(echo "$PERSONAL_PHONE" | sed 's/[^0-9]//g' | sed 's/^[0-9]\{1,2\}//')
    [ -n "$TEXT" ] && printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
}

# menu: Typing Tools | 📱 Type Phone formatted
type_phone_formatted() {
    TEXT="$PERSONAL_PHONE"
    [ -n "$TEXT" ] && printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
}

# menu: Typing Tools | 📋 Type clipboard
type_clipboard() {
    TEXT=$(wl-paste)
    [ -n "$TEXT" ] && printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
}

# menu: Typing Tools | 📅 Type date
type_date() { printf 'key leftctrl\ntype %s\n' "$(date --iso-8601)" | dotoolc; }

# menu: Typing Tools | 🏠 Type hostname
type_hostname() { printf 'key leftctrl\ntype %s\n' "$(hostname)/" | dotoolc; }

# menu: Typing Tools | 🏠 Type fritzbox
type_url_fritzbox() { printf 'key leftctrl\ntype %s\n' "http://fritz.box" | dotoolc; }

# menu: Typing Tools | 🏠 Type http+hostname
type_url_hostname() { printf 'key leftctrl\ntype %s\n' "http://$(hostname)/" | dotoolc; }

# menu: Typing Tools | 🎵 Type search audio
type_url_audio_search() { printf 'key leftctrl\ntype %s\n' "http://$(hostname)/audio/search_all" | dotoolc; }

# menu: Typing Tools | 🎮 Type solitaire
type_url_solitaire() { printf 'key leftctrl\ntype %s\n' "http://$(hostname)/shenzhen_solitaire/" | dotoolc; }

# menu: Typing Tools | 🖥️ Type kvm
type_url_kvm() { printf 'key leftctrl\ntype %s\n' "https://kvm" | dotoolc; }

# menu: Typing Tools | 🌐 Type local ip
type_ip_local() {
    TEXT=$(ip addr show | grep -i 'inet 192' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
    printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
}

# menu: Typing Tools | 🔑 Type vmpwd
type_vmpwd() {
    [ -n "$vmpwd" ] && printf 'key leftctrl\ntype %s\nkey Tab\nkey space\nkey Tab\nkey space\n' "$vmpwd" | dotoolc
}

# menu: Typing Tools | 🔐 Type veracrypt pwd
type_veracrypt_pwd() {
    [ -n "$veracryptpwd" ] && printf 'typedelay 20\nkeydelay 20\ntype %s\nkey Enter\nkey Enter\n' "$veracryptpwd" | dotoolc
}

# menu: Typing Tools | 📎 x0pipeclip
type_share_clip() {
    source /home/blu/scripts/functions/in_use/transfers/paste_services
    x0pipeclip "$(wl-paste)"
}


"$@"
