#!/bin/bash

# --- Execution Logic ---
# --- RDP Connections ---
# menu: RDP | RDP Connect to taiko-MS-7D51
rdp_connect_taiko_ms_7d51() {
	source /home/blu/.secure_env
    _rdp_connect "taiko-MS-7D51" "$taiko_MS_7D51_USER" "$taiko_MS_7D51_PWD"
}


# Only run dispatcher if executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
