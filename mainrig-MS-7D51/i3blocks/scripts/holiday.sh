#!/bin/bash

# Configuration file and colors
CONFIG_FILE="/home/blu/.config/i3blocks/i3blocks.conf"
ORIGINAL_COLOR="#FF8A65"
NEW_COLOR="#00FF00"

# Today's date and year
TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y)

# Define holidays for the current year in an associative array
declare -A holidays=(
    ["$YEAR-01-01"]="🎉 Neujahr"
    ["$YEAR-01-06"]="👑 Heilige Drei Könige"
    ["$YEAR-03-29"]="✝️ Karfreitag"
    ["$YEAR-04-01"]="🐣 Ostermontag"
    ["$YEAR-05-01"]="💼 Tag der Arbeit"
    ["$YEAR-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["$YEAR-11-01"]="🕊️ Allerheiligen"
    ["$YEAR-12-25"]="🎄 Erster Weihnachtstag"
    ["$YEAR-12-26"]="🎁 Zweiter Weihnachtstag"
)

# Get today's holiday if it exists, otherwise check for the next one in the next 365 days
today_holiday="${holidays[$TODAY]}"
next_holiday=""

# Loop to find the first upcoming holiday within the next 365 days
for i in {1..365}; do
    NEXT_DATE=$(date -d "$TODAY + $i days" +"%Y-%m-%d")
    if [[ -n "${holidays[$NEXT_DATE]}" ]]; then
        next_holiday="${holidays[$NEXT_DATE]} at $NEXT_DATE"
        break
    fi
done

# Display holiday status: today's, next one, or default message
echo "${today_holiday:-${next_holiday:-No holidays today, none are upcoming}}"

# Update i3blocks color based on whether today is a holiday
sed -i "s/color=$ORIGINAL_COLOR/color=${today_holiday:+$NEW_COLOR}$ORIGINAL_COLOR/g" "$CONFIG_FILE"