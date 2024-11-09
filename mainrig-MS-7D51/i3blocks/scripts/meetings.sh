#!/bin/bash

# Define meetings in the format: "DAY/DATE/NTH_WEEKDAY START END DESCRIPTION"
meetings=(
    "Mon 16:30 17:20 Team Sync"
    "14 14:00 15:00 Team Meeting"
    "3 Thu 10:30 10:55 1:1 Nicole"
)

# Get current day, date, and time
current_day=$(date '+%a')  # e.g., "Mon"
current_day_short=$(echo "$current_day" | awk '{print substr($0, 1, 3)}')  # e.g., "Mon"
current_date=$(date '+%d')  # Day of the month
current_time=$(date '+%H:%M')  # Current time in HH:MM format

# Debug output
echo "Current day: $current_day_short"
echo "Current date: $current_date"
echo "Current time: $current_time"

# Check each meeting and determine if it's active or next
for meeting in "${meetings[@]}"; do
    read -r day_or_date start end description <<< "$meeting"

    # Debugging output for each meeting
    echo "Checking meeting: $description"
    echo "Day/Date: $day_or_date, Start: $start, End: $end"

    # Handle day/weekday format
    if [[ "$day_or_date" == "$current_day_short" ]]; then
        echo "Meeting is on the same day: $current_day_short"
        
        if [[ "$current_time" > "$start" && "$current_time" < "$end" ]]; then
            echo "$description is in progress"
            break
        elif [[ "$current_time" < "$start" ]]; then
            echo "$description starts at $start"
        fi
    # Handle specific date (e.g., "14")
    elif [[ "$day_or_date" == "$current_date" ]]; then
        echo "Meeting is today ($current_date)"
        
        if [[ "$current_time" > "$start" && "$current_time" < "$end" ]]; then
            echo "$description is in progress"
            break
        elif [[ "$current_time" < "$start" ]]; then
            echo "$description starts at $start"
        fi
    fi
done
