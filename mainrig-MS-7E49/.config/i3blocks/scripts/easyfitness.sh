#!/bin/bash
# easyfitness.sh - Fixed and optimized for i3blocks

[ -f "$HOME/.secure_env" ] && source "$HOME/.secure_env"

declare -A SCHEDULE
SCHEDULE["1_10"]="Gemeinsam Gesund"; SCHEDULE["1_10.5"]="Rückenfit"; SCHEDULE["1_17.75"]="World Jumping"
SCHEDULE["1_18.75"]="Rückenfit"; SCHEDULE["1_19"]="Spinning Kurs"; SCHEDULE["1_19.5"]="Workout Mix"
SCHEDULE["1_20"]="Boxkurs"; SCHEDULE["2_17.75"]="Zumba"; SCHEDULE["2_18.75"]="Rückenfit"
SCHEDULE["2_19"]="Hyrox"; SCHEDULE["3_10"]="Yoga"; SCHEDULE["3_18"]="Piloxing Knockout"
SCHEDULE["3_18.5"]="Piloxing"; SCHEDULE["3_19"]="Piloxing Booty"; SCHEDULE["4_10"]="Gemeinsam Gesund"
SCHEDULE["4_10.5"]="Rückenfit"; SCHEDULE["4_16.5"]="Hip Hop Dance"; SCHEDULE["4_18"]="Piloxing Knockout"
SCHEDULE["4_18.5"]="Piloxing"; SCHEDULE["5_10"]="Yoga"; SCHEDULE["5_17.5"]="Dance Workout"
SCHEDULE["5_18"]="Hyrox"; SCHEDULE["6_10"]="Spinning"; SCHEDULE["6_11"]="World Jumping"
SCHEDULE["7_10"]="Piloxing"; SCHEDULE["7_10.75"]="Piloxing Booty"; SCHEDULE["7_11"]="Functional Kurs"
SCHEDULE["7_16"]="Power Yoga"; SCHEDULE["7_17"]="Hatha Yoga"

get_current_class() {
    local day=$(date +%u)
    local now_h=$(date +%H)
    local now_m=$(date +%M)
    # Convert current time to total minutes from midnight
    local now_total=$(( 10#$now_h * 60 + 10#$now_m ))

    for key in "${!SCHEDULE[@]}"; do
        # Check if the day matches
        [[ "${key%_*}" != "$day" ]] && continue
        
        # Extract the decimal hour (e.g., 10.75)
        local hour_dec="${key#*_}"
        
        # Use bc once to convert decimal hour to total minutes
        local sched_total=$(echo "$hour_dec * 60 / 1" | bc)
        
        # Calculate absolute difference
        local diff=$(( now_total - sched_total ))
        [[ $diff -lt 0 ]] && diff=$(( -diff ))
        
        # If within 12 minutes, we found our class
        if [[ $diff -le 12 ]]; then
            echo "${SCHEDULE[$key]}"
            return
        fi
    done
}

# Check Mullvad status via cache to avoid process forking
VPN_STATUS=$(< /tmp/mullvad_current_status)

if [[ "$VPN_STATUS" == "Connected" ]]; then
    read d h < <(date "+%u %k")
    # Business Hours Check
    if { ((d <= 5 && h >= 6 && h < 23)) || ((d >= 6 && h >= 8 && h < 21)); }; then
        
        # Fetch occupancy - pipe to sed to extract the percentage
        OCC=$(curl -s "https://easyfitness.club/studio/easyfitness-${CITY_HOME}/" | \
              sed -n 's/.*class="meterbubble">\([0-9]*\)%.*/\1/p' | head -n1)
        
        CURRENT_CLASS=$(get_current_class)
        
        if [[ -n "$CURRENT_CLASS" ]]; then
            echo "${OCC:-0}% Gym (likely full: $CURRENT_CLASS)"
        else
            echo "${OCC:-0}% Gym"
        fi
    else
        echo "Gym Closed"
    fi
else
    echo "VPN Offline"
fi