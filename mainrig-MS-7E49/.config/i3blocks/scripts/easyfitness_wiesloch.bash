#!/bin/bash

# Get current day of week (1=Mon … 7=Sun)
day=$(date +%u)
# Get current time in minutes since midnight
now=$(date +%H)*60 + $(date +%M)
now=$((now))

is_open=false

# Weekdays: Mon–Fri (1–5), open 06:00–23:00
if [ $day -ge 1 ] && [ $day -le 5 ]; then
    open=$((6*60))
    close=$((23*60))
    if [ $now -ge $open ] && [ $now -lt $close ]; then
        is_open=true
    fi
# Weekends: Sat–Sun (6–7), open 08:00–21:00
elif [ $day -ge 6 ] && [ $day -le 7 ]; then
    open=$((8*60))
    close=$((21*60))
    if [ $now -ge $open ] && [ $now -lt $close ]; then
        is_open=true
    fi
fi

if [ "$is_open" = true ]; then
    curl -s https://easyfitness.club/studio/easyfitness-wiesloch/ \
      | sed -n 's/.*class="meterbubble">\([0-9][0-9]*\)%.*/\1/p' \
      | head -n1 \
      | sed 's/$/% Gym/'
else
    echo "Gym Closed"
fi
