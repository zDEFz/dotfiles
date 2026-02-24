#!/bin/bash
# 5PX_POWER_DRAW.sh - Optimized for i3blocks

# Configuration
HOST="eaton-5PX-2200i"
COMMUNITY="public"
MIB_PATH="/usr/share/snmp/mibs:$HOME/MIBs"
KWH_PRICE_MILLICENTS=350 # 0.35 * 1000 to avoid floats in bash

# 1. Fetch data - Using -Oqv to get values only
# We read into a variable first to avoid multiple forks
raw_data=$(snmpget -v2c -c "$COMMUNITY" -M "$MIB_PATH" -m XUPS-MIB -Oqv "$HOST" \
    XUPS-MIB::xupsOutputPercentLoad.1 \
    XUPS-MIB::xupsOutputTotalWatts.0 \
    XUPS-MIB::xupsBatTimeRemaining.0 \
    XUPS-MIB::xupsBatCapacity.0 2>/dev/null)

# Convert multiline string to array without calling 'tr'
data="($raw_data)"

ld=${data[0]:-0}
wt=${data[1]:-0}
tr=${data[2]:-0}
bc=${data[3]:-0}

# 2. Native Bash Calculations
time_h=$((tr / 3600))
time_m=$(( (tr % 3600) / 60 ))

# Calculate costs in "millicents" then format with printf
# Daily: (Watts * 24 hours * Price) / 1000
d_total_mc=$(( wt * 24 * KWH_PRICE_MILLICENTS / 1000 ))
m_total_mc=$(( wt * 730 * KWH_PRICE_MILLICENTS / 1000 ))

# Format as currency (converts e.g., 350 to 0.35)
d_cost=$(printf "%d.%02d" $((d_total_mc/100)) $((d_total_mc%100)))
m_cost=$(printf "%d.%02d" $((m_total_mc/100)) $((m_total_mc%100)))

# 3. i3blocks Output
echo ">>> ${ld}% ${wt}W | bat ${bc}% ${time_h}h${time_m}m | EUR ${d_cost}/d | EUR ${m_cost}/mo"
echo "${wt}W | EUR ${m_cost}/mo"

if [ "$bc" -lt 50 ]; then
    echo "#FF0000"
fi
