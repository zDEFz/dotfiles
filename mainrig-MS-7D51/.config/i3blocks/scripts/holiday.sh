#!/bin/bash

# Colors for holiday and non-holiday states
HOLIDAY_COLOR="yellow"  # New color for holidays
DEFAULT_COLOR="white"  # Original color

# Today's date and year
TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y)

# Define holidays for the current year in an associative array
declare -A holidays=(
    ["2025-01-01"]="🎉 Neujahr"
    ["2025-01-06"]="👑 Heilige Drei Könige"
    ["2025-04-18"]="✝️ Karfreitag"      # Good Friday (2 days before Easter Sunday on April 20, 2025)
    ["2025-04-21"]="🐣 Ostermontag"    # Easter Monday (1 day after Easter Sunday on April 20, 2025)
    ["2025-05-01"]="💼 Tag der Arbeit"
    ["2025-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2025-11-01"]="🕊️ Allerheiligen"
    ["2025-12-25"]="🎄 Erster Weihnachtstag"
    ["2025-12-26"]="🎁 Zweiter Weihnachtstag"
)

# Get today's holiday if it exists, otherwise check for the next one in the next 365 days
today_holiday="${holidays[$TODAY]}"
next_holiday=""

# Loop to find the first upcoming holiday within the next 365 days
for i in {1..365}; do
    NEXT_DATE=$(date -d "$TODAY + $i days" +"%Y-%m-%d")
    if [[ -n "${holidays[$NEXT_DATE]}" ]]; then
        next_holiday="${holidays[$NEXT_DATE]} on $NEXT_DATE"
        break
    fi
done

# Determine display message and color
display_message="${today_holiday:-${next_holiday:-No holidays today, none are upcoming}}"
color="${today_holiday:+$HOLIDAY_COLOR}"
color="${color:-$DEFAULT_COLOR}"

# Output with Pango markup
echo "<span color=\"$color\">$display_message</span>"
