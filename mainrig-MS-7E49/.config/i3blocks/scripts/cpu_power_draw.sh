#!/bin/bash
# Optimized i3blocks power script (No umlauts used)
STATE_FILE="/dev/shm/pwr_state"
ENERGY_FILE="/sys/class/powercap/intel-rapl:0/energy_uj"

# 1. Read energy (Fastest)
if ! read -r E2 < "$ENERGY_FILE" 2>/dev/null; then
    echo "Perm Error" && exit 1
fi

# 2. Get time in nanoseconds
# Use printf %(%s%N)T if bash 5.0+, otherwise fallback to date
if [[ -n ${BASH_VERSINFO[0]} && ${BASH_VERSINFO[0]} -ge 5 ]]; then
    printf -v T2 "%(%s%N)T" -1
    # Check if %N was literally printed (some bash builds dont support it)
    if [[ "$T2" == *"%N"* ]]; then T2=$(date +%s%N); fi
else
    T2=$(date +%s%N)
fi

# 3. Process previous state
if [[ -f "$STATE_FILE" ]]; then
    read -r E1 T1 < "$STATE_FILE"
    
    DE=$((E2 - E1))
    DT=$((T2 - T1))
    
    # Handle counter resets (Intel RAPL overflows at ~2^32 or 2^64 microjoules)
    if (( DT > 0 && DE >= 0 )); then
        # Power (W) calculation:
        # P = (DE / 10^6) / (DT / 10^9)
        # P = (DE * 1000) / DT
        # To get 2 decimal places (X.XX):
        # W_100 = (DE * 1000 * 100) / DT
        W_100=$(( (DE * 100000) / DT ))
        
        printf "%d.%02dW\n" $((W_100 / 100)) $((W_100 % 100))
    else
        echo "Updating..."
    fi
else
    echo "Initial..."
fi

# 4. Save state to RAM
echo "$E2 $T2" > "$STATE_FILE"
