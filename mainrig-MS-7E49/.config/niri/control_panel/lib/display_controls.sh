#!/bin/bash

# --- CATEGORY: DISPLAY CONTROLS ---
# Individual Controls

# menu: Display Controls | ✅ Emergency Power outage mode 
display_power_outage_mode() { 
	for d in "$L" "$R" "$LL" "$RR"; do swaymsg output "'$d'" disable; done; 
}

# menu: Display Controls | ✅ Enable L
display_L_on() { swaymsg output "'$L'" enable; }

# menu: Display Controls | ❌ Disable L
display_L_off() { swaymsg output "'$L'" disable; }

# menu: Display Controls | ✅ Enable LL
display_LL_on() { swaymsg output "'$LL'" enable; }

# menu: Display Controls | ❌ Disable LL
display_LL_off() { swaymsg output "'$LL'" disable; }

# menu: Display Controls | ❌ Disable LL and Disable RR
display_LL_RR_off() { swaymsg output "'$LL'" disable; swaymsg output "'$RR'" disable; }

# menu: Display Controls | ✅ Enable LL and Enable RR
enable_LL_RR_on() { swaymsg output "'$LL'" enable; swaymsg output "'$RR'" enable; }

# menu: Display Controls | ✅ Enable M
display_M_on() { swaymsg output "'$M'" enable; }

# menu: Display Controls | ❌ Disable M
display_M_off() { swaymsg output "'$M'" disable; }

# menu: Display Controls | ✅ Enable MON_KB
display_MON_KB_on() { swaymsg output "'$MON_KB'" enable; }

# menu: Display Controls | ❌ Disable MON_KB
display_MON_KB_off() { swaymsg output "'$MON_KB'" disable; }

# menu: Display Controls | ✅ Enable R
display_R_on() { swaymsg output "'$R'" enable; }

# menu: Display Controls | ❌ Disable R
display_R_off() { swaymsg output "'$R'" disable; }

# menu: Display Controls | ❌ Disable L and Disable R
display_L_R_off() { swaymsg output "'$L'" disable; swaymsg output "'$R'" disable; }

# menu: Display Controls | ✅ Enable L and Enable R
enable_L_R_on() { swaymsg output "'$L'" enable; swaymsg output "'$R'" enable; }

# menu: Display Controls | ✅ Enable RR
display_RR_on() { swaymsg output "'$RR'" enable; }

# menu: Display Controls | ❌ Disable RR
display_RR_off() { swaymsg output "'$RR'" disable; }

# menu: Display Controls | ✅ Enable TAIKO
display_TAIKO_on() { swaymsg output "'$TAIKO'" enable; }

# menu: Display Controls | ❌ Disable TAIKO
display_TAIKO_off() { swaymsg output "'$TAIKO'" disable; }

# Group Controls
# menu: Display Controls | ❌ Disable support all
display_group_all_off() { for d in "$L" "$M" "$R" "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable all Seat Displays
display_group_seat_on() { for d in "$L" "$LL" "$M" "$MON_KB" "$R" "$RR"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | ❌ Disable all Seat Displays
display_group_seat_off() { for d in "$L" "$LL" "$M" "$MON_KB" "$R" "$RR"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | 🔄 Set refresh rate
display_set_hz() {
	source "$HOME/scripts/functions/video"
    local RATE
    
    if [[ -n "$1" ]]; then
        RATE="$1"
    else
        RATE=$(wofi --insensitive --dmenu -p "Hz")
    fi

    [[ -z "$RATE" ]] && return

    # We use a for loop with a subshell result
    # This is often more reliable than a pipe for simple string lists
    for i in $(lshz | grep -o "DP-[0-9]"); do
        swaymsg output "$i" resolution 1920x1080@"$RATE"Hz
    done
}


# Only run dispatcher if executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
