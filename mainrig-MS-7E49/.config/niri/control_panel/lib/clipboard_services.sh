#!/bin/bash

# menu: Clipboard Services | 📎 x0pipeclip
clipboard_to_x0() {
    source /home/blu/scripts/functions/paste_services
    x0pipeclip "$(wl-paste)"
}


# Only run dispatcher if executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
