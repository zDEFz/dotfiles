#!/bin/bash

declare -A S=( 
    ["1_10"]="Gesund" ["1_10.5"]="Rückenfit" ["1_17.75"]="Jumping" ["1_18.75"]="Rückenfit" ["1_19"]="Spinning" ["1_19.5"]="Workout" ["1_20"]="Boxen"
    ["2_17.75"]="Zumba" ["2_18.75"]="Rückenfit" ["2_19"]="Hyrox"
    ["3_10"]="Yoga" ["3_18"]="P-Knockout" ["3_18.5"]="Piloxing" ["3_19"]="P-Booty"
    ["4_10"]="Gesund" ["4_10.5"]="Rückenfit" ["4_16.5"]="HipHop" ["4_18"]="P-Knockout" ["4_18.5"]="Piloxing"
    ["5_10"]="Yoga" ["5_17.5"]="Dance" ["5_18"]="Hyrox"
    ["6_10"]="Spinning" ["6_11"]="Jumping"
    ["7_10"]="Piloxing" ["7_10.75"]="P-Booty" ["7_11"]="Functional" ["7_16"]="Power Yoga" ["7_17"]="Hatha"
)

# Checks
! mullvad status | grep -q "Connected" && echo "Gym (No VPN)" && exit
D=$(date +%u); H=$((10#$(date +%H))); M=$((10#$(date +%M)))
(( (D<6 && (H<6 || H>22)) || (D>5 && (H<8 || H>20)) )) && echo "Gym closed" && exit

# Fetch & Identify
OCC=$(curl -s https://easyfitness.club/studio/easyfitness-wiesloch/ | grep -oP 'meterbubble">\K[0-9]+')
NOW=$(awk "BEGIN {print $H + ($M/60)}")

for t in "${!S[@]}"; do
    [[ ${t%_*} == "$D" ]] && near=$(awk "BEGIN {print ( ($NOW - ${t#*_})^2 < 0.04 )}")
    [[ "$near" == 1 ]] && CLASS="${S[$t]}" && break
done

echo "${OCC}% Gym${CLASS:+ (Class: $CLASS)}"
