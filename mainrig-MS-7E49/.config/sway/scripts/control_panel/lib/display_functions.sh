#!/bin/bash

# Internal helper
_disp() { swaymsg output "'${!2}'" "$1"; }

# menu: Display Controls | 🔄 Set refresh rate
set_refresh_rate() {
    local rate=$(wofi --dmenu -p "Hz")
    [ -z "$rate" ] && return
    for i in $(lshz | grep -o "DP-[0-9]"); do
        swaymsg output "$i" resolution 1920x1080@"$rate"Hz
    done
}

# menu: Display Controls | ✅ Enable L
enable_L() { _disp enable L; }
# menu: Display Controls | ❌ Disable L
disable_L() { _disp disable L; }
# menu: Display Controls | ✅ Enable LL
enable_LL() { _disp enable LL; }
# menu: Display Controls | ❌ Disable LL
disable_LL() { _disp disable LL; }
# menu: Display Controls | ✅ Enable M
enable_M() { _disp enable M; }
# menu: Display Controls | ❌ Disable M
disable_M() { _disp disable M; }
# menu: Display Controls | ✅ Enable MON_KB
enable_MON_KB() { _disp enable MON_KB; }
# menu: Display Controls | ❌ Disable MON_KB
disable_MON_KB() { _disp disable MON_KB; }
# menu: Display Controls | ✅ Enable R
enable_R() { _disp enable R; }
# menu: Display Controls | ❌ Disable R
disable_R() { _disp disable R; }
# menu: Display Controls | ✅ Enable RR
enable_RR() { _disp enable RR; }
# menu: Display Controls | ❌ Disable RR
disable_RR() { _disp disable RR; }
# menu: Display Controls | ✅ Enable TAIKO
enable_TAIKO() { _disp enable TAIKO; }
# menu: Display Controls | ❌ Disable TAIKO
disable_TAIKO() { _disp disable TAIKO; }

# Group Controls
# menu: Display Controls | ✅ Enable main support
enable_main() { for d in L M R; do _disp enable $d; done; }
# menu: Display Controls | ❌ Disable main support
disable_main() { for d in L M R; do _disp disable $d; done; }
# menu: Display Controls | ✅ Enable main support and taiko
enable_main_taiko() { for d in L M R TAIKO; do _disp enable $d; done; }
# menu: Display Controls | ❌ Disable main support and taiko
disable_main_taiko() { for d in L M R TAIKO; do _disp disable $d; done; }
# menu: Display Controls | ✅ Enable opt support
enable_opt() { for d in LL MON_KB RR; do _disp enable $d; done; }
# menu: Display Controls | ❌ Disable opt support
disable_opt() { for d in LL MON_KB RR; do _disp disable $d; done; }
# menu: Display Controls | ✅ Enable opt support and taiko
enable_opt_taiko() { for d in LL MON_KB RR TAIKO; do _disp enable $d; done; }
# menu: Display Controls | ❌ Disable opt support and taiko
disable_opt_taiko() { for d in LL MON_KB RR TAIKO; do _disp disable $d; done; }
# menu: Display Controls | ✅ Enable support all
enable_supp_all() { for d in L M R LL MON_KB RR; do _disp enable $d; done; }
# menu: Display Controls | ❌ Disable support all
disable_supp_all() { for d in L M R LL MON_KB RR; do _disp disable $d; done; }
# menu: Display Controls | Enable all Seat Displays
enable_all_seat() { for d in L LL M MON_KB R RR; do _disp enable $d; done; }