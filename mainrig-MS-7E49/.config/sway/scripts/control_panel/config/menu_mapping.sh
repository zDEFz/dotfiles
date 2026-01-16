#!/bin/bash
# menu_mapping.sh - All menu items and their commands

declare -A MENU_MAP=(
    # Typing Tools
    ["Type clipboard"]="type_clipboard"
    ["Type date"]="type_date"
    ["Type hostname"]="type_hostname"
    ["Type local ip"]="type_local_ip"
    ["Type vmpwd"]="type_vmpwd"
    ["Type veracrypt pwd"]="type_veracrypt_pwd"
    ["Share clipboard (x0pipe)"]="share_clipboard_text"
    
    # Swayr / Window Management
    ["Steal window"]="swayr_steal_window"
    ["Switch window"]="swayr_switch_window"
    ["Switch workspace"]="swayr_switch_workspace"
    ["Move focused to workspace"]="swayr_move_focused_to_workspace"
    
    # Display Movements (Using the new generic move_to function)
    ["Move to L"]="move_to L"
    ["Move to LL"]="move_to LL"
    ["Move to M"]="move_to M"
    ["Move to MON_KB"]="move_to MON_KB"
    ["Move to R"]="move_to R"
    ["Move to RR"]="move_to RR"
    ["Move to TAIKO"]="move_to TAIKO"
    
    # Display Toggles (Using the new generic display_cmd function)
    ["Enable L"]="display_cmd enable L"
    ["Disable L"]="display_cmd disable L"
    ["Enable All Seat Displays"]="display_cmd enable L LL M MON_KB R RR"
    ["Enable Support All"]="display_cmd enable L M R LL MON_KB RR"
    ["Disable Support All"]="display_cmd disable L M R LL MON_KB RR"
    ["Enable Main Support + Taiko"]="display_cmd enable L M R TAIKO"
    ["Disable Main Support + Taiko"]="display_cmd disable L M R TAIKO"
    
    # Applications
    ["Focus OpenTaiko"]="focus_opentaiko"
    ["Kill Cultris II"]="kill_cultris2"
    ["Realign mpv Openmusic"]="realign_mpv_openmusic"
    ["Follow journalctl"]="follow_journalctl"
    ["Set refresh rate"]="set_refresh_rate"
    ["MAL Synopsis from clipboard"]="myanimelist_synopsis_clipboard"
)