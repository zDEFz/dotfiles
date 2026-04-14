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


# Only run dispatcher if executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
