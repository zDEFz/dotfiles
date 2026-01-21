#!/bin/bash

# ------------------------------
# GROUP CLASS SCHEDULE (from image)
# Format: SCHEDULE[DAY][HOUR]="Class Name"
# Day: 1=Mon ... 7=Sun
# Hour = integer hour of start (24h)
# ------------------------------
declare -A SCHEDULE

# MONDAY (1)
SCHEDULE["1_10"]="Gemeinsam Gesund"
SCHEDULE["1_10.5"]="Rückenfit"
SCHEDULE["1_17.75"]="World Jumping"
SCHEDULE["1_18.75"]="Rückenfit"
SCHEDULE["1_19"]="Spinning Kurs"
SCHEDULE["1_19.5"]="Workout Mix"
SCHEDULE["1_20"]="Boxkurs"

# TUESDAY (2)
SCHEDULE["2_17.75"]="Zumba"
SCHEDULE["2_18.75"]="Rückenfit"
SCHEDULE["2_19"]="Hyrox"

# WEDNESDAY (3)
SCHEDULE["3_10"]="Yoga"
SCHEDULE["3_18"]="Piloxing Knockout"
SCHEDULE["3_18.5"]="Piloxing"
SCHEDULE["3_19"]="Piloxing Booty"

# THURSDAY (4)
SCHEDULE["4_10"]="Gemeinsam Gesund"
SCHEDULE["4_10.5"]="Rückenfit"
SCHEDULE["4_16.5"]="Hip Hop Dance"
SCHEDULE["4_18"]="Piloxing Knockout"
SCHEDULE["4_18.5"]="Piloxing"

# FRIDAY (5)
SCHEDULE["5_10"]="Yoga"
SCHEDULE["5_17.5"]="Dance Workout"
SCHEDULE["5_18"]="Hyrox"

# SATURDAY (6)
SCHEDULE["6_10"]="Spinning"
SCHEDULE["6_11"]="World Jumping"

# SUNDAY (7)
SCHEDULE["7_10"]="Piloxing"
SCHEDULE["7_10.75"]="Piloxing Booty"
SCHEDULE["7_11"]="Functional Kurs"
SCHEDULE["7_16"]="Power Yoga"
SCHEDULE["7_17"]="Hatha Yoga"

# --------------------------------------
# FUNCTION: determine if a class is now
# --------------------------------------
get_current_class() {
    local day hour minute key

    day=$(date +%u)
    hour=$(date +%H)
    minute=$(date +%M)

    # Convert HH:MM into decimal hour
    hour_decimal=$(awk "BEGIN {print $hour + ($minute/60)}")

    # Check ±10 min window for start times
    # Check ±10 min window for start times
    for t in "${!SCHEDULE[@]}"; do
        d="${t%_*}"
        h="${t#*_}"

        # Compare only classes for this weekday
        if [[ "$d" == "$day" ]]; then
            diff=$(awk "BEGIN {print ($hour_decimal - $h)}")

            # If class start time is within ±0.2 hours (~12 minutes)
            is_near=$(awk "BEGIN {print (sqrt($diff*$diff) < 0.20)}")

            if [[ "$is_near" == 1 ]]; then
                echo "${SCHEDULE[$t]}"
                return
            fi
        fi
    done

    echo ""
}

# Check if Mullvad VPN is connected
if mullvad status | grep -q "Connected"; then
    DAY=$(date +%u)
    HOUR=$((10#$(date +%H)))

    # BUSINESS HOURS
    if [[ "$DAY" -ge 1 && "$DAY" -le 5 && "$HOUR" -ge 6 && "$HOUR" -lt 23 ]] || \
       [[ "$DAY" -eq 6 && "$HOUR" -ge 8 && "$HOUR" -lt 21 ]] || \
       [[ "$DAY" -eq 7 && "$HOUR" -ge 8 && "$HOUR" -lt 21 ]]; then

        # Fetch occupancy
        OCC=$(curl -s https://easyfitness.club/studio/easyfitness-"$CITY_HOME"/ \
            | sed -n 's/.*class="meterbubble">\([0-9][0-9]*\)%.*/\1/p' \
            | head -n1)

        # Detect if a class is causing crowding
        CURRENT_CLASS=$(get_current_class)

        if [[ -n "$CURRENT_CLASS" ]]; then
            echo "${OCC}% Gym (likely full due to: $CURRENT_CLASS)"
        else
            echo "${OCC}% Gym"
        fi

    else
        echo "Outside business hours, skipping command."
    fi
else
    echo "Not connected to Mullvad, skipping command."
fi
