#!/bin/bash
# ups_get_wattage.sh - Strict Validation

HOST="eaton-5PX-2200i"
COMMUNITY="public"
MIB_PATH="/usr/share/snmp/mibs:/home/$(whoami)/MIBs"
KWH_PRICE=0.35
CACHE="/dev/shm/ups_data"

while true; do
    # 1. Fetch data
    mapfile -t data < <(snmpget -v2c -c "$COMMUNITY" -M "$MIB_PATH" -m XUPS-MIB -Oqvn "$HOST" \
        XUPS-MIB::xupsOutputPercentLoad.1 \
        XUPS-MIB::xupsOutputTotalWatts.0 \
        XUPS-MIB::xupsBatTimeRemaining.0 \
        XUPS-MIB::xupsBatCapacity.0 2>/dev/null | tr -cd '0-9\n')

    # Assign variables
    ld=${data[0]}
    wt=${data[1]}
    tr=${data[2]}
    bc=${data[3]}

    # 2. THE STRICT CHECK
    # We only update if wt (Watts) is a number AND is greater than 10.
    # If the UPS returns 0, or the string is empty, we SKIP writing.
    if [[ -n "$wt" ]] && [ "$wt" -gt 10 ] 2>/dev/null; then
        
        # 3. Calculations
        time_fmt="$((tr/3600))h$(((tr%3600)/60))m"
        m_cost=$(echo "scale=2; ($wt * 730 / 1000) * $KWH_PRICE" | bc)
        d_cost=$(echo "scale=2; ($wt * 24 / 1000) * $KWH_PRICE" | bc)

        # 4. Atomic Write
        {
            echo ">>> ${ld}% ${wt}W | bat ${bc}% ${time_fmt} | €${d_cost}/d | €${m_cost}/mo"
            echo "${wt}W | €${m_cost}/mo"
            if [ "$bc" -lt 50 ]; then echo "#FF0000"; fi
        } > "${CACHE}.tmp"
        
        mv "${CACHE}.tmp" "$CACHE"
    fi

    sleep 1
done
