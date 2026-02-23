#!/bin/bash
# 5PX_POWER_DRAW.sh - Optimized for i3blocks

# Configuration
HOST="eaton-5PX-2200i"
COMMUNITY="public"
MIB_PATH="/usr/share/snmp/mibs:$HOME/MIBs"
KWH_PRICE=0.35

# 1. Fetch data
mapfile -t data < <(snmpget -v2c -c "$COMMUNITY" -M "$MIB_PATH" -m XUPS-MIB -Oqvn "$HOST" \
    XUPS-MIB::xupsOutputPercentLoad.1 \
    XUPS-MIB::xupsOutputTotalWatts.0 \
    XUPS-MIB::xupsBatTimeRemaining.0 \
    XUPS-MIB::xupsBatCapacity.0 2>/dev/null | tr -cd '0-9\n')

ld=${data[0]:-0}
wt=${data[1]:-0}
tr=${data[2]:-0}
bc=${data[3]:-0}

# 2. Calculations
time_fmt="$((tr/3600))h$(((tr%3600)/60))m"

# Monthly cost (730 hours)
m_cost=$(echo "scale=2; ($wt * 730 / 1000) * $KWH_PRICE" | bc)
# Daily cost (24 hours)
d_cost=$(echo "scale=2; ($wt * 24 / 1000) * $KWH_PRICE" | bc)

# 3. i3blocks Output
# Line 1: Full text (Visible on the bar)
echo ">>> ${ld}% ${wt}W | bat ${bc}% ${time_fmt} | €${d_cost}/d | €${m_cost}/mo"

# Line 2: Short text (Only shows if space is very tight)
echo "${wt}W | €${m_cost}/mo"

# Line 3: Color
if [ "$bc" -lt 50 ]; then
    echo "#FF0000"
fi
