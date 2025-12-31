#!/bin/bash

# Colors
HOLIDAY_COLOR="yellow"
DEFAULT_COLOR="white"

TODAY_TS=$(date -d "today 00:00:00" +%s)
CURRENT_YEAR=$(date +%Y)

# Function to get holiday dates for a specific year
get_holidays() {
    local yr=$1
    # 1. Calculate Easter Sunday (using the Orthodox/Western Christian formula)
    # This is a common shell implementation of the Gauss algorithm
    local a=$(( yr % 19 ))
    local b=$(( yr / 100 ))
    local c=$(( yr % 100 ))
    local d=$(( b / 4 ))
    local e=$(( b % 4 ))
    local f=$(( (b + 8) / 25 ))
    local g=$(( (b - f + 1) / 3 ))
    local h=$(( (19 * a + b - d - g + 15) % 30 ))
    local i=$(( c / 4 ))
    local k=$(( c % 4 ))
    local l=$(( (32 + 2 * e + 2 * i - h - k) % 7 ))
    local m=$(( (a + 11 * h + 22 * l) / 451 ))
    local month=$(( (h + l - 7 * m + 114) / 31 ))
    local day=$(( ((h + l - 7 * m + 114) % 31) + 1 ))
    
    local easter_date=$(printf "%04d-%02d-%02d" $yr $month $day)

    # Fixed Dates
    echo "$yr-01-01|🎉 Neujahr"
    echo "$yr-01-06|👑 Heilige Drei Könige"
    echo "$yr-05-01|💼 Tag der Arbeit"
    echo "$yr-10-03|🇩🇪 Tag der Deutschen Einheit"
    echo "$yr-11-01|🕊️ Allerheiligen"
    echo "$yr-12-25|🎄 Erster Weihnachtstag"
    echo "$yr-12-26|🎁 Zweiter Weihnachtstag"
    echo "$yr-12-31|🎆 Silvester"

    # Moving Dates (Relative to Easter)
    echo "$(date -d "$easter_date - 2 days" +%Y-%m-%d)|✝️ Karfreitag"
    echo "$(date -d "$easter_date + 1 days" +%Y-%m-%d)|🐣 Ostermontag"
    echo "$(date -d "$easter_date + 39 days" +%Y-%m-%d)|☁️ Christi Himmelfahrt"
    echo "$(date -d "$easter_date + 50 days" +%Y-%m-%d)|🕊️ Pfingstmontag"
}

# Collect holidays for current and next year (to handle December look-ahead)
all_holidays=$( (get_holidays $CURRENT_YEAR; get_holidays $((CURRENT_YEAR + 1))) | sort -u )

display_message="No upcoming holidays"
color=$DEFAULT_COLOR

# Find the first holiday that is today or in the future
while IFS='|' read -r hdate hname; do
    h_ts=$(date -d "$hdate 00:00:00" +%s)
    
    if [[ "$h_ts" -eq "$TODAY_TS" ]]; then
        display_message="Today: $hname"
        color=$HOLIDAY_COLOR
        break
    elif [[ "$h_ts" -gt "$TODAY_TS" ]]; then
        display_message="$hname ($hdate)"
        color=$DEFAULT_COLOR
        break
    fi
done <<< "$all_holidays"

echo "<span color=\"$color\">$display_message</span>"
