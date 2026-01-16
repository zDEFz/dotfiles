#!/bin/bash

# Internal helper
_mov() { swaymsg move container to output "'${!1}'"; }

# menu: Move Window to Display | Move to L
mov_L() { _mov L; }
# menu: Move Window to Display | Move to LL
mov_LL() { _mov LL; }
# menu: Move Window to Display | Move to M
mov_M() { _mov M; }
# menu: Move Window to Display | Move to MON_KB
mov_MON_KB() { _mov MON_KB; }
# menu: Move Window to Display | Move to R
mov_R() { _mov R; }
# menu: Move Window to Display | Move to RR
mov_RR() { _mov RR; }
# menu: Move Window to Display | 🥁 Move to TAIKO
mov_TAIKO() { _mov TAIKO; }

# menu: Swayr Window Management | Steal window
sw_steal() { swayr steal-window; }
# menu: Swayr Window Management | Switch window
sw_switch() { swayr switch-window; }
# menu: Swayr Window Management | Switch workspace
sw_work() { swayr switch-workspace; }
# menu: Swayr Window Management | Move focused to workspace
sw_move() { swayr move-focused-to-workspace; }