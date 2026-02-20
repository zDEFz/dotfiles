#!/bin/bash

# Configuration
HOST="eaton-5PX-2200i"
COMMUNITY="public"
MIB_PATH="/usr/share/snmp/mibs:$HOME/MIBs"

# List your OIDs here in the order you want them fetched
OIDS=(
    "XUPS-MIB::xupsOutputPercentLoad.1"
    "XUPS-MIB::xupsOutputTotalWatts.0"
    "XUPS-MIB::xupsBatTimeRemaining.0"
    "XUPS-MIB::xupsBatCapacity.0"
)

# 1. Fetch data into a temporary array
mapfile -t data < <(snmpget -v2c -c "$COMMUNITY" -M "$MIB_PATH" -m XUPS-MIB -Oqvn "$HOST" "${OIDS[@]}" 2>/dev/null | tr -cd '0-9\n')

# 2. Explictly name them for readability
ld=${data[0]:-0}
wt=${data[1]:-0}
tr=${data[2]:-0}
bc=${data[3]:-0}

# 3. Format time (1h30m)
time_fmt="$((tr/3600))h$(((tr%3600)/60))m"

# 4. Final Output
echo ">>> ${ld}% ${wt}W | bat ${bc}% ${time_fmt}"



