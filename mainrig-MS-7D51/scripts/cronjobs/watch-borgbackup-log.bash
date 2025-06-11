#!/bin/bash
NON_ROOT_USER="blu"
USER_HOME="/home/$NON_ROOT_USER"

# Path to the notification script
NOTIFY_SCRIPT="${USER_HOME}"/git/mainrig-MS-7D51/scripts/cronjobs/notify-borgbackup.bash  # Update with the actual path to your notify script

# Log file path
LOG_FILE="${USER_HOME}"/cron_logs/borgbackup.log

# Ensure the log file exists
touch $LOG_FILE

# Watch the log file and send notifications
tail -n 0 -F $LOG_FILE | while read LINE; do
    echo "$(date +'%Y-%m-%d %H:%M:%S') DEBUG: New line detected: $LINE" >> "${USER_HOME}"/cron_logs/watcher_debug.log  # Debug output

    if [[ "$LINE" == *"Snapshot already exists"* ]]; then
        MESSAGE=$(echo "$LINE" | grep -o 'Snapshot already exists: .*$')
        echo "$(date +'%Y-%m-%d %H:%M:%S') DEBUG: Sending notification for: $MESSAGE" >> "${USER_HOME}"/cron_logs/watcher_debug.log  # Debug output
        $NOTIFY_SCRIPT "$MESSAGE"
    elif [[ "$LINE" == *"Created Btrfs snapshot"* ]]; then
        MESSAGE=$(echo "$LINE" | grep -o 'Created Btrfs snapshot: .*$')
        echo "$(date +'%Y-%m-%d %H:%M:%S') DEBUG: Sending notification for: $MESSAGE" >> "${USER_HOME}"/cron_logs/watcher_debug.log  # Debug output
        $NOTIFY_SCRIPT "$MESSAGE"
    elif [[ "$LINE" == *"Backup to"* ]]; then
        MESSAGE=$(echo "$LINE" | grep -o 'Backup to .*$')
        echo "$(date +'%Y-%m-%d %H:%M:%S') DEBUG: Sending notification for: $MESSAGE" >> "${USER_HOME}"/cron_logs/watcher_debug.log  # Debug output
        $NOTIFY_SCRIPT "$MESSAGE"
    elif [[ "$LINE" == *"Backup to"* ]]; then
        MESSAGE=$(echo "$LINE" | grep -o 'Backup to .*$')
        echo "$(date +'%Y-%m-%d %H:%M:%S') DEBUG: Sending notification for: $MESSAGE" >> "${USER_HOME}"/cron_logs/watcher_debug.log  # Debug output
        $NOTIFY_SCRIPT "$MESSAGE"
    elif [[ "$LINE" == *"Backup to"* ]]; then
        MESSAGE=$(echo "$LINE" | grep -o 'Backup to .*$')
        echo "$(date +'%Y-%m-%d %H:%M:%S') DEBUG: Sending notification for: $MESSAGE" >> "${USER_HOME}"/cron_logs/watcher_debug.log  # Debug output
        $NOTIFY_SCRIPT "$MESSAGE"
    elif [[ "$LINE" == *"Backup to"* ]]; then
        MESSAGE=$(echo "$LINE" | grep -o 'Backup to .*$')
        echo "$(date +'%Y-%m-%d %H:%M:%S') DEBUG: Sending notification for: $MESSAGE" >> "${USER_HOME}"/cron_logs/watcher_debug.log  # Debug output
        $NOTIFY_SCRIPT "$MESSAGE"
    fi
done
