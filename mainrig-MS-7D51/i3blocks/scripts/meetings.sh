#!/bin/bash

# Define meetings in the format: "DAY/DATE/NTH_WEEKDAY START END DESCRIPTION"
meetings=(
    "Mon 16:30 17:20 Team Sync"
    "14 14:00 15:00 Team Meeting"
    "3 Thu 10:30 10:55 1:1 Nicole"
)

# Get current day, date, time
current_day=$(date '+%a')  # Full weekday name (e.g., "Fri")
current_day_short=$(echo "$current_day" | awk '{print substr($0, 1, 3)}')  # Abbreviate to "Fri", "Mon", etc.
current_date=$(date '+%d')
current_time=$(date '+%H:%M')

# Function to calculate time difference in human-readable format (h min)
time_difference_human_readable() {
    local start_time=$1
    local current_time=$2
    local start_seconds=$(date -d "$start_time" +%s)
    local current_seconds=$(date -d "$current_time" +%s)
    local total_minutes=$(( (start_seconds - current_seconds) / 60 ))
    
    if (( total_minutes >= 60 )); then
        local hours=$(( total_minutes / 60 ))
        local minutes=$(( total_minutes % 60 ))
        echo "${hours}h ${minutes}m"
    else
        echo "${total_minutes}m"
    fi
}

# Function to calculate time difference in minutes (for notifications)
time_difference_minutes() {
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

    # If the meeting is based on the nth weekday (e.g., "3 Mon")
    if [[ $day_or_date =~ ^([1-5])\ ([A-Za-z]{3})$ ]]; then
        nth="${BASH_REMATCH[1]}"
        weekday="${BASH_REMATCH[2]}"
        weekday_idx=$(date -d "$weekday" +%w)
        first_day_of_month_idx=$(date -d "$(date +%Y-%m-01)" +%w)
        nth_day=$(( (nth - 1) * 7 + weekday_idx - first_day_of_month_idx ))
        nth_day=$(( nth_day < 0 ? nth_day + 7 : nth_day ))

        if [[ "$current_date" == "$(printf "%02d" "$((nth_day + 1))")" ]]; then
            if [[ "$current_time" > "$start" && "$current_time" < "$end" ]]; then
                meeting_active="<span color='red'>$description in progress</span>"
                break
            elif [[ -z "$next_meeting" && "$current_time" < "$start" ]]; then
                countdown=$(time_difference_human_readable "$start" "$current_time")
                next_meeting="<span color='white'>$description in $countdown</span>"
            fi
        fi
    # If the meeting is based on a specific day of the week (e.g., "Fri")
    elif [[ "$day_or_date" == "$current_day_short" ]]; then
        if [[ "$current_time" > "$start" && "$current_time" < "$end" ]]; then
            meeting_active="<span color='red'>$description in progress</span>"
            break
        elif [[ -z "$next_meeting" && "$current_time" < "$start" ]]; then
            countdown=$(time_difference_human_readable "$start" "$current_time")
            next_meeting="<span color='white'>$description in $countdown</span>"
        fi
    # If the meeting is based on a specific date (e.g., "14")
    elif [[ "$day_or_date" == "$current_date" ]]; then
        if [[ "$current_time" > "$start" && "$current_time" < "$end" ]]; then
            meeting_active="<span color='red'>$description in progress</span>"
            break
        elif [[ -z "$next_meeting" && "$current_time" < "$start" ]]; then
            countdown=$(time_difference_human_readable "$start" "$current_time")
            next_meeting="<span color='white'>$description in $countdown</span>"
        fi
    fi

    # Calculate minutes until start for notification
    minutes_until_start=$(time_difference_minutes "$start" "$current_time")

    # Send notifications 30, 15, 10, and 5 minutes before the meeting starts
    case $minutes_until_start in
        30) notify-send "$description" "Meeting starts in 30 minutes" ;;
        15) notify-send "$description" "Meeting starts in 15 minutes" ;;
        10) notify-send "$description" "Meeting starts in 10 minutes" ;;
         5) notify-send "$description" "Meeting starts in 5 minutes" ;;
    esac
done

# Handle the case where next meeting is based on weekdays (e.g., Monday)
if [[ -z "$next_meeting" && -z "$meeting_active" ]]; then
    for meeting in "${meetings[@]}"; do
        read -r day_or_date start end description <<< "$meeting"
        if [[ "$day_or_date" =~ ^[A-Za-z]{3}$ ]]; then
            if [[ "$day_or_date" == "$current_day_short" ]]; then
                continue  # Skip if the meeting is for today.
            elif [[ "$day_or_date" == "Mon" && "$current_day_short" != "Mon" ]]; then
                next_meeting="<span color='white'>$description on Mon at $start - $end</span>"
            fi
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