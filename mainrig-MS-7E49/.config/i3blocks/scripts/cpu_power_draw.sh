#!/bin/bash
# Optimized i3blocks power script
STATE_FILE="/dev/shm/pwr_state"
ENERGY_FILE="/sys/class/powercap/intel-rapl:0/energy_uj"

# 1. Read energy using built-in redirection (Fastest)
if ! read -r E2 < "$ENERGY_FILE" 2>/dev/null; then
    echo "Access Denied" && exit 1
fi

# 2. Get time in nanoseconds (with fallback)
if command -v date >/dev/null 2>&1; then
    T2=$(date +%s%N 2>/dev/null)
    # If %N not supported, fall back to seconds with 9 zeros
    if [[ "$T2" == *"%N"* ]]; then
        T2=$(date +%s)000000000
    fi
else
    # Pure bash fallback (seconds only, less precise)
    printf -v T2 "%(%s)T" -1
    T2=${T2}000000000
fi

if [[ -f "$STATE_FILE" ]]; then
    read -r E1 T1 < "$STATE_FILE"
    
    DE=$((E2 - E1))
    DT=$((T2 - T1))
    
    # Fix: Check DT > 0 before division
    if (( DT > 0 && DE >= 0 )); then
        # Energy in microjoules, time in nanoseconds
        # Power (W) = (DE µJ / 1e6) / (DT ns / 1e9) = DE * 1000 / DT
        W_100=$(( (DE * 100000) / DT ))
        # Output: X.XXW
        printf "%d.%02dW\n" $((W_100 / 100)) $((W_100 % 100))
    fi
fi

# 3. Save state to RAM
echo "$E2 $T2" > "$STATE_FILE"
