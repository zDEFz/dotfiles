#!/bin/bash

# menu: Display Controls | ✅ Enable L
enable_L() { swaymsg output "'$L'" enable; }
# menu: Display Controls | ❌ Disable L
disable_L() { swaymsg output "'$L'" disable; }

# menu: Display Controls | ✅ Enable LL
enable_LL() { swaymsg output "'$LL'" enable; }
# menu: Display Controls | ❌ Disable LL
disable_LL() { swaymsg output "'$LL'" disable; }

# menu: Display Controls | ✅ Enable M
enable_M() { swaymsg output "'$M'" enable; }
# menu: Display Controls | ❌ Disable M
disable_M() { swaymsg output "'$M'" disable; }

# menu: Display Controls | ✅ Enable MON_KB
enable_MON_KB() { swaymsg output "'$MON_KB'" enable; }
# menu: Display Controls | ❌ Disable MON_KB
disable_MON_KB() { swaymsg output "'$MON_KB'" disable; }

# menu: Display Controls | ✅ Enable R
enable_R() { swaymsg output "'$R'" enable; }
# menu: Display Controls | ❌ Disable R
disable_R() { swaymsg output "'$R'" disable; }

# menu: Display Controls | ✅ Enable RR
enable_RR() { swaymsg output "'$RR'" enable; }
# menu: Display Controls | ❌ Disable RR
disable_RR() { swaymsg output "'$RR'" disable; }

# menu: Display Controls | ✅ Enable TAIKO
enable_TAIKO() { swaymsg output "'$TAIKO'" enable; }
# menu: Display Controls | ❌ Disable TAIKO
disable_TAIKO() { swaymsg output "'$TAIKO'" disable; }

# Group Controls
# menu: Display Controls | ✅ Enable main support
enable_main_support() { for d in "$L" "$M" "$R"; do swaymsg output "'$d'" enable; done; }
# menu: Display Controls | ❌ Disable main support
disable_main_support() { for d in "$L" "$M" "$R"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable main support and taiko
enable_main_support_and_taiko() { for d in "$L" "$M" "$R" "$TAIKO"; do swaymsg output "'$d'" enable; done; }
# menu: Display Controls | ❌ Disable main support and taiko
disable_main_support_and_taiko() { for d in "$L" "$M" "$R" "$TAIKO"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable opt support
enable_opt_support() { for d in "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" enable; done; }
# menu: Display Controls | ❌ Disable opt support
disable_opt_support() { for d in "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable opt support and taiko
enable_opt_support_and_taiko() { for d in "$LL" "$MON_KB" "$RR" "$TAIKO"; do swaymsg output "'$d'" enable; done; }
# menu: Display Controls | ❌ Disable opt support and taiko
disable_opt_support_and_taiko() { for d in "$LL" "$MON_KB" "$RR" "$TAIKO"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable support all
enable_support_all() { for d in "$L" "$M" "$R" "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" enable; done; }
# menu: Display Controls | ❌ Disable support all
disable_support_all() { for d in "$L" "$M" "$R" "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | Enable all Seat Displays
enable_all_seat_displays() { for d in "$L" "$LL" "$M" "$MON_KB" "$R" "$RR"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | 🔄 Set refresh rate
set_refresh_rate() {
    RATE=$(wofi --insensitive --dmenu -p "Hz")
    [ -z "$RATE" ] && return
    for i in $(lshz | grep -o "DP-[0-9]"); do swaymsg output "$i" resolution 1920x1080@"$RATE"Hz; done
}