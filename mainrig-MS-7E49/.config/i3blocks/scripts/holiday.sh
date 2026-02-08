#!/bin/bash
# holiday.sh - Highly efficient holiday tracker for i3blocks

TODAY=$(date +%Y-%m-%d)
YR=$(date +%Y)

get_holidays() {
    local yr=$1
    # Gauss algorithm for Easter Sunday
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
    
    # Base Easter Date
    local easter=$(date -d "$yr-03-01 +$((day-1)) days +$((month-3)) months" +%Y-%m-%d)

    # Fixed Holidays
    printf "%s-01-01|🎉 Neujahr\n" "$yr"
    printf "%s-01-06|👑 Drei Könige\n" "$yr"
    printf "%s-05-01|💼 Tag der Arbeit\n" "$yr"
    printf "%s-10-03|🇩🇪 Dt. Einheit\n" "$yr"
    printf "%s-11-01|🕊️ Allerheiligen\n" "$yr"
    printf "%s-12-25|🎄 1. Weihnacht\n" "$yr"
    printf "%s-12-26|🎁 2. Weihnacht\n" "$yr"
    printf "%s-12-31|🎆 Silvester\n" "$yr"

    # Moving Holidays (Relative to Easter)
    date -d "$easter - 2 days" +"%Y-%m-%d|✝️ Karfreitag"
    date -d "$easter + 1 days" +"%Y-%m-%d|🐣 Ostermontag"
    date -d "$easter + 39 days" +"%Y-%m-%d|☁️ Christi Himmelfahrt"
    date -d "$easter + 50 days" +"%Y-%m-%d|🕊️ Pfingstmontag"
}

# Fetch holidays. Only look at next year if we are at the very end of December.
H_LIST=$(get_holidays "$YR")
if [[ "$TODAY" > "$YR-12-26" ]]; then
    H_LIST+=$'\n'$(get_holidays $((YR+1)))
fi

# Sort and find the first holiday that is today or in the future
while IFS='|' read -r hdate hname; do
    if [[ "$hdate" == "$TODAY" ]]; then
        echo "<span color=\"yellow\">Today: $hname</span>"
        exit 0
    elif [[ "$hdate" > "$TODAY" ]]; then
        echo "<span>$hname ($hdate)</span>"
        exit 0
    fi
done < <(echo "$H_LIST" | sort)

echo "No upcoming holidays"