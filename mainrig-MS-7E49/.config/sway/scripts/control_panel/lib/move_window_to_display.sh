#!/bin/bash

# --- CATEGORY: MOVE WINDOW TO DISPLAY ---
# menu: Move Window to Display | 🪟 Move to L
win_move_L() { _win_move_to_output L; }

# menu: Move Window to Display | 🪟 Move to LL
win_move_LL() { _win_move_to_output LL; }

# menu: Move Window to Display | 🪟 Move to M
win_move_M() { _win_move_to_output M; }

# menu: Move Window to Display | 🪟 Move to MON_KB
win_move_MON_KB() { _win_move_to_output MON_KB; }

# menu: Move Window to Display | 🪟 Move to R
win_move_R() { _win_move_to_output R; }

# menu: Move Window to Display | 🪟 Move to RR
win_move_RR() { _win_move_to_output RR; }

# menu: Move Window to Display | 🥁 Move to TAIKO
win_move_TAIKO() { _win_move_to_output TAIKO; }


"$@"
