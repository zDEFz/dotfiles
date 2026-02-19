#!/bin/bash

# Configuration
HOST="eaton-5PX-2200i"
COMMUNITY="public"
MIB_PATH="/usr/share/snmp/mibs:$HOME/MIBs"

# 1. Fetch only the reliable data points
mapfile -t data < <(snmpget -v2c -c "$COMMUNITY" -M "$MIB_PATH" -m XUPS-MIB -Oqvn "$HOST" \
    XUPS-MIB::xupsOutputTotalWatts.0 \
    XUPS-MIB::xupsBatTimeRemaining.0 \
    XUPS-MIB::xupsBatCapacity.0 \
    2>/dev/null | tr -dc '0-9\n')

# 2. Assign variables
out_w=${data[0]:-0}
secs=${data[1]:-0}
chg=${data[2]:-0}

# 3. Format Time
hrs=$(( secs / 3600 ))
min=$(( (secs % 3600) / 60 ))

# 4. Final Output (Efficiency removed per your request)
echo "${out_w}W | ${hrs}h ${min}m | ${chg}% chg"