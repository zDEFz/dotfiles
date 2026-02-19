#!/bin/bash

# Configuration
HOST="eaton_5PX_2200i"
COMMUNITY="public"
MIB_PATH="/usr/share/snmp/mibs:$HOME/MIBs"

# 1. Fetch data into a numbered array using mapfile
# -Oqvn: 'v' for values only, 'n' for numeric output, 'q' for quick/clean
mapfile -t data < <(snmpget -v2c -c "$COMMUNITY" "$HOST" \
    -M "$MIB_PATH" -m XUPS-MIB -Oqvn \
    XUPS-MIB::xupsOutputWatts.1 \
    XUPS-MIB::xupsBatTimeRemaining.0 \
    XUPS-MIB::xupsBatCapacity.0 2>/dev/null | tr -cd '0-9\n')

# 2. Assign variables with defaults
# Use ${var:-0} to prevent "empty" errors in math
watts=${data[0]:-0}
secs=${data[1]:-0}
chg=${data[2]:-0}

# 3. Calculate time
hrs=$(( secs / 3600 ))
min=$(( (secs % 3600) / 60 ))

# 4. Final Output
echo "${watts}W | ${hrs}h ${min}m | ${chg}% chg"
