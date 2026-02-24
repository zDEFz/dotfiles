#!/bin/bash
# ups_get_wattage.sh - Pull-based with 1s cache protection

HOST="eaton-5PX-2200i"
COMMUNITY="public"
MIB_PATH="/usr/share/snmp/mibs:/home/$(whoami)/MIBs"
KWH_PRICE=0.35
CACHE="/dev/shm/ups_data"
NOW=$(date +%s)
LAST_UPDATE=$(stat -c %Y "$CACHE" 2>/dev/null || echo 0)

# 1. Fetch data only if cache is old
if [ $((NOW - LAST_UPDATE)) -ge 1 ]; then
    mapfile -t data < <(snmpget -v2c -c "$COMMUNITY" -M "$MIB_PATH" -m XUPS-MIB -Oqvn "$HOST" \
        XUPS-MIB::xupsOutputPercentLoad.1 \
        XUPS-MIB::xupsOutputTotalWatts.0 \
        XUPS-MIB::xupsBatTimeRemaining.0 \
        XUPS-MIB::xupsBatCapacity.0 2>/dev/null | tr -cd '0-9\n')

    ld=${data[0]}
    wt=${data[1]}
    tr=${data[2]}
    bc=${data[3]}

    if [[ -n "$wt" ]] && [ "$wt" -gt 10 ] 2>/dev/null; then
        time_fmt="$((tr/3600))h$(((tr%3600)/60))m"
        m_cost=$(echo "scale=2; ($wt * 730 / 1000) * $KWH_PRICE" | bc)
        d_cost=$(echo "scale=2; ($wt * 24 / 1000) * $KWH_PRICE" | bc)

        # 2. Build the output (Exactly 2 lines to match your preference)
        # Line 1: Full text
        # Line 2: Short text
        OUT=">>> ${ld}% ${wt}W | bat ${bc}% ${time_fmt} | €${d_cost}/d | €${m_cost}/mo\n"
        OUT+="${wt}W | €${m_cost}/mo\n"

        # Atomic write to cache
        printf "%b" "$OUT" > "${CACHE}.tmp"
        mv "${CACHE}.tmp" "$CACHE"
    fi
fi

# 3. Always output the current cache
cat "$CACHE" 2>/dev/null
