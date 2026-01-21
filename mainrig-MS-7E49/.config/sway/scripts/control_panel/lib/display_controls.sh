#!/bin/bash

# --- CATEGORY: DISPLAY CONTROLS ---
# Individual Controls
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

# menu: Display Controls | ✅ Enable RR
display_RR_on() { swaymsg output "'$RR'" enable; }

# menu: Display Controls | ❌ Disable RR
display_RR_off() { swaymsg output "'$RR'" disable; }

# menu: Display Controls | ✅ Enable TAIKO
display_TAIKO_on() { swaymsg output "'$TAIKO'" enable; }

# menu: Display Controls | ❌ Disable TAIKO
display_TAIKO_off() { swaymsg output "'$TAIKO'" disable; }

# Group Controls
# menu: Display Controls | ✅ Enable main support
display_group_main_on() { for d in "$L" "$M" "$R"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | ❌ Disable main support
display_group_main_off() { for d in "$L" "$M" "$R"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable main support and taiko
display_group_main_taiko_on() { for d in "$L" "$M" "$R" "$TAIKO"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | ❌ Disable main support and taiko
display_group_main_taiko_off() { for d in "$L" "$M" "$R" "$TAIKO"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable opt support
display_group_opt_on() { for d in "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | ❌ Disable opt support
display_group_opt_off() { for d in "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable opt support and taiko
display_group_opt_taiko_on() { for d in "$LL" "$MON_KB" "$RR" "$TAIKO"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | ❌ Disable opt support and taiko
display_group_opt_taiko_off() { for d in "$LL" "$MON_KB" "$RR" "$TAIKO"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable support all
display_group_all_on() { for d in "$L" "$M" "$R" "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | ❌ Disable support all
display_group_all_off() { for d in "$L" "$M" "$R" "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable all Seat Displays
display_group_seat_on() { for d in "$L" "$LL" "$M" "$MON_KB" "$R" "$RR"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | 🔄 Set refresh rate
display_set_hz() {
    RATE=$(wofi --insensitive --dmenu -p "Hz")
    [ -z "$RATE" ] && return
    for i in $(lshz | grep -o "DP-[0-9]"); do swaymsg output "$i" resolution 1920x1080@"$RATE"Hz; done
}


"$@"
