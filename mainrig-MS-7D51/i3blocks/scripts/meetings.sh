#!/bin/bash

start_time=$(date +%s.%N)

# Define meetings in the format: "DAY/DATE/NTH_WEEKDAY START END DESCRIPTION"
meetings=(
    "Mon 16:30 17:20 Team Sync"
    "14 14:00 15:00 Team Meeting"
    "3 Thu 10:30 10:55 1:1 Nicole"
)

# Get current day, date, time, month, and year
current_day=$(date '+%a')
current_date=$(date '+%d')
current_time=$(date '+%H:%M')
current_month=$(date '+%m')
current_year=$(date '+%Y')

# Precompute weekday indices for the current month
weekday_idx=$(date -d "$current_day" +%w)
first_day_of_month_idx=$(date -d "$current_year-$current_month-01" +%w)

# Helper function to calculate nth weekday in a month (optimized)
nth_weekday_in_month() {
    local nth=$1
    local weekday=$2
    local weekday_idx=$3
    local first_day_of_month_idx=$4
    local day_offset=$(( (nth - 1) * 7 + weekday_idx - first_day_of_month_idx ))
    day_offset=$(( day_offset < 0 ? day_offset + 7 : day_offset ))
    printf "%02d" "$(( day_offset + 1 ))"  # Return the 1-based day
}

# Function to calculate time difference in minutes
time_difference() {
    local start_time=$1
    local current_time=$2
    local start_seconds=$(date -d "$start_time" +%s)
    local current_seconds=$(date -d "$current_time" +%s)
    echo $(( (start_seconds - current_seconds) / 60 ))
}

# Initialize variables to track meeting status
meeting_active=""
next_meeting=""

# Check each meeting and determine if it's active or next
for meeting in "${meetings[@]}"; do
    read -r day_or_date start end description <<< "$meeting"

    # If the meeting is based on the nth weekday (e.g., "3 Thu")
    if [[ $day_or_date =~ ^([1-5])\ ([A-Za-z]{3})$ ]]; then
        nth="${BASH_REMATCH[1]}"
        weekday="${BASH_REMATCH[2]}"
        weekday_idx=$(date -d "$weekday" +%w)
        nth_day=$(nth_weekday_in_month "$nth" "$weekday" "$weekday_idx" "$first_day_of_month_idx")

        if [[ "$current_date" == "$nth_day" ]]; then
            if [[ "$current_time" > "$start" && "$current_time" < "$end" ]]; then
                meeting_active="<span color='red'>$description in progress</span>"
                break
            elif [[ -z "$next_meeting" && "$current_time" < "$start" ]]; then
                countdown=$(time_difference "$start" "$current_time")
                next_meeting="<span color='white'>$description in $countdown minutes</span>"
            fi
        fi
    # If the meeting is based on a specific day of the week (e.g., "Mon", "Tue")
    elif [[ "$day_or_date" == "$current_day" ]]; then
        if [[ "$current_time" > "$start" && "$current_time" < "$end" ]]; then
            meeting_active="<span color='red'>$description in progress</span>"
            break
        elif [[ -z "$next_meeting" && "$current_time" < "$start" ]]; then
            countdown=$(time_difference "$start" "$current_time")
            next_meeting="<span color='white'>$description in $countdown minutes</span>"
        fi
    # If the meeting is based on a specific date (e.g., "14")
    elif [[ "$day_or_date" == "$current_date" ]]; then
        if [[ "$current_time" > "$start" && "$current_time" < "$end" ]]; then
            meeting_active="<span color='red'>$description in progress</span>"
            break
        elif [[ -z "$next_meeting" && "$current_time" < "$start" ]]; then
            countdown=$(time_difference "$start" "$current_time")
            next_meeting="<span color='white'>$description in $countdown minutes</span>"
        fi
    fi
done

# Handle the case where next meeting is based on weekdays (e.g., Monday)
if [[ -z "$next_meeting" && -z "$meeting_active" ]]; then
    for meeting in "${meetings[@]}"; do
        read -r day_or_date start end description <<< "$meeting"
        if [[ "$day_or_date" =~ ^[A-Za-z]{3}$ ]]; then
            next_weekday=$(date -d "$current_day + 1 week" '+%a')
            next_meeting="<span color='white'>$description on $next_weekday at $start - $end</span>"
            break
        fi
    done
fi

# Output the result in a single line
if [[ -n "$meeting_active" ]]; then
    echo "$meeting_active"
else
    echo "$next_meeting"
fi


end_time=$(date +%s.%N)
elapsed_time=$(echo "$end_time - $start_time" | bc)
