#!/bin/bash

# Path to the i3blocks configuration file
CONFIG_FILE="/home/blu/.config/i3blocks/i3blocks.conf"
# Backup of the original color
ORIGINAL_COLOR="#FF8A65"
# Bright purple color
NEW_COLOR="#00FF00"  # You can change this to your preferred bright purple

# Fetch today's date in YYYY-MM-DD format
TODAY=$(date +%Y-%m-%d)
# Hardcoded holidays for Baden-Württemberg from 2024 to 2040
declare -A holidays
holidays=(
    # 2024 Holidays
    ["2024-01-01"]="🎉 Neujahr"
    ["2024-01-06"]="👑 Heilige Drei Könige"
    ["2024-03-29"]="✝️ Karfreitag"
    ["2024-04-01"]="🐣 Ostermontag"
    ["2024-05-01"]="💼 Tag der Arbeit"
    ["2024-05-09"]="☁️ Christi Himmelfahrt"
    ["2024-05-20"]="🌼 Pfingstmontag"
    ["2024-05-30"]="🍞 Fronleichnam"
    ["2024-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2024-11-01"]="🕊️ Allerheiligen"
    ["2024-12-25"]="🎄 Erster Weihnachtstag"
    ["2024-12-26"]="🎁 Zweiter Weihnachtstag"
    
    # 2025 Holidays
    ["2025-01-01"]="🎉 Neujahr"
    ["2025-01-06"]="👑 Heilige Drei Könige"
    ["2025-04-18"]="✝️ Karfreitag"
    ["2025-04-21"]="🐣 Ostermontag"
    ["2025-05-01"]="💼 Tag der Arbeit"
    ["2025-05-29"]="☁️ Christi Himmelfahrt"
    ["2025-06-09"]="🌼 Pfingstmontag"
    ["2025-06-19"]="🍞 Fronleichnam"
    ["2025-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2025-11-01"]="🕊️ Allerheiligen"
    ["2025-12-25"]="🎄 Erster Weihnachtstag"
    ["2025-12-26"]="🎁 Zweiter Weihnachtstag"
    
    # 2026 Holidays
    ["2026-01-01"]="🎉 Neujahr"
    ["2026-01-06"]="👑 Heilige Drei Könige"
    ["2026-04-03"]="✝️ Karfreitag"
    ["2026-04-06"]="🐣 Ostermontag"
    ["2026-05-01"]="💼 Tag der Arbeit"
    ["2026-05-14"]="☁️ Christi Himmelfahrt"
    ["2026-05-25"]="🌼 Pfingstmontag"
    ["2026-06-04"]="🍞 Fronleichnam"
    ["2026-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2026-11-01"]="🕊️ Allerheiligen"
    ["2026-12-25"]="🎄 Erster Weihnachtstag"
    ["2026-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2027 Holidays
    ["2027-01-01"]="🎉 Neujahr"
    ["2027-01-06"]="👑 Heilige Drei Könige"
    ["2027-03-26"]="✝️ Karfreitag"
    ["2027-03-29"]="🐣 Ostermontag"
    ["2027-05-06"]="☁️ Christi Himmelfahrt"
    ["2027-05-17"]="🌼 Pfingstmontag"
    ["2027-05-27"]="🍞 Fronleichnam"
    ["2027-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2027-11-01"]="🕊️ Allerheiligen"
    ["2027-12-25"]="🎄 Erster Weihnachtstag"
    ["2027-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2028 Holidays
    ["2028-01-01"]="🎉 Neujahr"
    ["2028-01-06"]="👑 Heilige Drei Könige"
    ["2028-04-14"]="✝️ Karfreitag"
    ["2028-04-17"]="🐣 Ostermontag"
    ["2028-05-25"]="💼 Tag der Arbeit"
    ["2028-06-05"]="🌼 Pfingstmontag"
    ["2028-06-15"]="🍞 Fronleichnam"
    ["2028-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2028-11-01"]="🕊️ Allerheiligen"
    ["2028-12-25"]="🎄 Erster Weihnachtstag"
    ["2028-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2029 Holidays
    ["2029-01-01"]="🎉 Neujahr"
    ["2029-01-06"]="👑 Heilige Drei Könige"
    ["2029-03-30"]="✝️ Karfreitag"
    ["2029-04-02"]="🐣 Ostermontag"
    ["2029-05-10"]="☁️ Christi Himmelfahrt"
    ["2029-05-21"]="🌼 Pfingstmontag"
    ["2029-05-31"]="🍞 Fronleichnam"
    ["2029-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2029-11-01"]="🕊️ Allerheiligen"
    ["2029-12-25"]="🎄 Erster Weihnachtstag"
    ["2029-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2030 Holidays
    ["2030-01-01"]="🎉 Neujahr"
    ["2030-01-06"]="👑 Heilige Drei Könige"
    ["2030-04-19"]="✝️ Karfreitag"
    ["2030-04-22"]="🐣 Ostermontag"
    ["2030-05-01"]="💼 Tag der Arbeit"
    ["2030-05-30"]="☁️ Christi Himmelfahrt"
    ["2030-06-10"]="🌼 Pfingstmontag"
    ["2030-06-20"]="🍞 Fronleichnam"
    ["2030-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2030-11-01"]="🕊️ Allerheiligen"
    ["2030-12-25"]="🎄 Erster Weihnachtstag"
    ["2030-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2031 Holidays
    ["2031-01-01"]="🎉 Neujahr"
    ["2031-01-06"]="👑 Heilige Drei Könige"
    ["2031-04-11"]="✝️ Karfreitag"
    ["2031-04-14"]="🐣 Ostermontag"
    ["2031-05-22"]="💼 Tag der Arbeit"
    ["2031-06-02"]="🌼 Pfingstmontag"
    ["2031-06-12"]="🍞 Fronleichnam"
    ["2031-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2031-11-01"]="🕊️ Allerheiligen"
    ["2031-12-25"]="🎄 Erster Weihnachtstag"
    ["2031-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2032 Holidays
    ["2032-01-01"]="🎉 Neujahr"
    ["2032-01-06"]="👑 Heilige Drei Könige"
    ["2032-03-26"]="✝️ Karfreitag"
    ["2032-03-29"]="🐣 Ostermontag"
    ["2032-05-06"]="☁️ Christi Himmelfahrt"
    ["2032-05-17"]="🌼 Pfingstmontag"
    ["2032-05-27"]="🍞 Fronleichnam"
    ["2032-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2032-11-01"]="🕊️ Allerheiligen"
    ["2032-12-25"]="🎄 Erster Weihnachtstag"
    ["2032-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2033 Holidays
    ["2033-01-01"]="🎉 Neujahr"
    ["2033-01-06"]="👑 Heilige Drei Könige"
    ["2033-04-15"]="✝️ Karfreitag"
    ["2033-04-18"]="🐣 Ostermontag"
    ["2033-05-26"]="☁️ Christi Himmelfahrt"
    ["2033-06-06"]="🌼 Pfingstmontag"
    ["2033-06-16"]="🍞 Fronleichnam"
    ["2033-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2033-11-01"]="🕊️ Allerheiligen"
    ["2033-12-25"]="🎄 Erster Weihnachtstag"
    ["2033-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2034 Holidays
    ["2034-01-01"]="🎉 Neujahr"
    ["2034-01-06"]="👑 Heilige Drei Könige"
    ["2034-04-07"]="✝️ Karfreitag"
    ["2034-04-10"]="🐣 Ostermontag"
    ["2034-05-18"]="☁️ Christi Himmelfahrt"
    ["2034-05-29"]="🌼 Pfingstmontag"
    ["2034-06-08"]="🍞 Fronleichnam"
    ["2034-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2034-11-01"]="🕊️ Allerheiligen"
    ["2034-12-25"]="🎄 Erster Weihnachtstag"
    ["2034-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2035 Holidays
    ["2035-01-01"]="🎉 Neujahr"
    ["2035-01-06"]="👑 Heilige Drei Könige"
    ["2035-03-23"]="✝️ Karfreitag"
    ["2035-03-26"]="🐣 Ostermontag"
    ["2035-05-03"]="☁️ Christi Himmelfahrt"
    ["2035-05-14"]="🌼 Pfingstmontag"
    ["2035-05-24"]="🍞 Fronleichnam"
    ["2035-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2035-11-01"]="🕊️ Allerheiligen"
    ["2035-12-25"]="🎄 Erster Weihnachtstag"
    ["2035-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2036 Holidays
    ["2036-01-01"]="🎉 Neujahr"
    ["2036-01-06"]="👑 Heilige Drei Könige"
    ["2036-04-11"]="✝️ Karfreitag"
    ["2036-04-14"]="🐣 Ostermontag"
    ["2036-05-22"]="💼 Tag der Arbeit"
    ["2036-06-02"]="🌼 Pfingstmontag"
    ["2036-06-12"]="🍞 Fronleichnam"
    ["2036-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2036-11-01"]="🕊️ Allerheiligen"
    ["2036-12-25"]="🎄 Erster Weihnachtstag"
    ["2036-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2037 Holidays
    ["2037-01-01"]="🎉 Neujahr"
    ["2037-01-06"]="👑 Heilige Drei Könige"
    ["2037-04-03"]="✝️ Karfreitag"
    ["2037-04-06"]="🐣 Ostermontag"
    ["2037-05-14"]="☁️ Christi Himmelfahrt"
    ["2037-05-25"]="🌼 Pfingstmontag"
    ["2037-06-04"]="🍞 Fronleichnam"
    ["2037-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2037-11-01"]="🕊️ Allerheiligen"
    ["2037-12-25"]="🎄 Erster Weihnachtstag"
    ["2037-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2038 Holidays
    ["2038-01-01"]="🎉 Neujahr"
    ["2038-01-06"]="👑 Heilige Drei Könige"
    ["2038-04-23"]="✝️ Karfreitag"
    ["2038-04-26"]="🐣 Ostermontag"
    ["2038-06-03"]="☁️ Christi Himmelfahrt"
    ["2038-06-14"]="🌼 Pfingstmontag"
    ["2038-06-24"]="🍞 Fronleichnam"
    ["2038-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2038-11-01"]="🕊️ Allerheiligen"
    ["2038-12-25"]="🎄 Erster Weihnachtstag"
    ["2038-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2039 Holidays
    ["2039-01-01"]="🎉 Neujahr"
    ["2039-01-06"]="👑 Heilige Drei Könige"
    ["2039-04-08"]="✝️ Karfreitag"
    ["2039-04-11"]="🐣 Ostermontag"
    ["2039-05-19"]="☁️ Christi Himmelfahrt"
    ["2039-05-30"]="🌼 Pfingstmontag"
    ["2039-06-09"]="🍞 Fronleichnam"
    ["2039-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2039-11-01"]="🕊️ Allerheiligen"
    ["2039-12-25"]="🎄 Erster Weihnachtstag"
    ["2039-12-26"]="🎁 Zweiter Weihnachtstag"

    # 2040 Holidays
    ["2040-01-01"]="🎉 Neujahr"
    ["2040-01-06"]="👑 Heilige Drei Könige"
    ["2040-03-30"]="✝️ Karfreitag"
    ["2040-04-02"]="🐣 Ostermontag"
    ["2040-05-10"]="💼 Tag der Arbeit"
    ["2040-05-21"]="🌼 Pfingstmontag"
    ["2040-05-31"]="🍞 Fronleichnam"
    ["2040-10-03"]="🇩🇪 Tag der Deutschen Einheit"
    ["2040-11-01"]="🕊️ Allerheiligen"
    ["2040-12-25"]="🎄 Erster Weihnachtstag"
    ["2040-12-26"]="🎁 Zweiter Weihnachtstag"
)

# Initialize variables
today_holiday=""
next_holiday=""

# Check if today is a holiday
if [[ -n "${holidays[$TODAY]}" ]]; then
    today_holiday="${holidays[$TODAY]} today"
fi

# Loop through the next 365 days to find the next holiday
for i in {1..365}; do
    DATE=$(date -d "$TODAY + $i days" +%Y-%m-%d)
    HOLIDAY="${holidays[$DATE]}"

    if [[ -n "$HOLIDAY" ]]; then
        next_holiday="$HOLIDAY at $DATE"
        break
    fi
done

# Output the results on the same line
if [[ -n "$today_holiday" ]]; then
    echo "$today_holiday"
fi

if [[ -n "$next_holiday" ]]; then
    echo "$next_holiday"
fi

# Modify the configuration file based on whether today is a holiday
if [[ -n "$today_holiday" ]]; then
    # If today is a holiday, replace the color with bright purple
    sed -i "s/color=$ORIGINAL_COLOR/color=$NEW_COLOR/g" "$CONFIG_FILE"
else
    # If not a holiday, revert to the original color
    sed -i "s/color=$NEW_COLOR/color=$ORIGINAL_COLOR/g" "$CONFIG_FILE"
fi

# Only print a message if there are no holidays today and none upcoming
if [[ -z "$today_holiday" && -z "$next_holiday" ]]; then
    echo "No holidays today, none are upcoming"
fi