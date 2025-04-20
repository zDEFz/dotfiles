#!/bin/bash

# Function to check current focus and signal code-server
check_focus_and_signal() {
    echo "[DEBUG] Checking for running 'code-server' process..."

    # Get code-server PIDs using pgrep, excluding this script's process
    pids=$(pgrep -f -- 'code-server' | grep -v $$)

    # If no code-server is running, output debug message and return
    if [ -z "$pids" ]; then
        echo "[DEBUG] No running 'code-server' process found."
        return
    fi

    echo "[DEBUG] Found running 'code-server' process with PID(s): $pids"

    # Check the current status of the code-server processes
    echo "[DEBUG] Checking the status of code-server processes before sending signal..."
    echo "$pids" | xargs -n 1 ps -o pid,stat,comm

    # Get the app_id of the currently focused window
    echo "[DEBUG] Fetching focused window's app_id..."
    focused_app_id=$(swaymsg -t get_tree | jq -r '
      recurse(.nodes[]?, .floating_nodes[]?) 
      | select(.focused == true) 
      | .app_id // empty
    ')

    # Log the app_id of the focused window
    echo "[DEBUG] Focused window app_id: '$focused_app_id'" 

    # Check if the focused app_id ends with `-code`
    if [[ "$focused_app_id" =~ -code$ ]]; then
        echo "[DEBUG] Focused window app_id ends with '-code'. Sending SIGCONT to 'code-server'."
        # Send SIGCONT to code-server processes
        echo "$pids" | xargs -r -n 1 kill -CONT
    else
        echo "[DEBUG] Focused window app_id does NOT end with '-code'. Sending SIGSTOP to 'code-server'."
        # Send SIGSTOP to code-server processes
        echo "$pids" | xargs -r -n 1 kill -STOP
    fi

    # Show status after sending the signal
    echo "[DEBUG] Checking the status of code-server processes after sending signal..."
    echo "$pids" | xargs -n 1 ps -o pid,stat,comm
}

# Infinite loop to ensure swaymsg subscribe never drops the script
while true; do
    echo "[DEBUG] Waiting for workspace change events from swaymsg..."
    
    # Subscribe to workspace events and listen for workspace changes
    swaymsg -t subscribe '[ "workspace" ]' | while read -r line; do
        echo "[DEBUG] Received swaymsg event: $line"  # Log the full event

        # Only trigger check when there's a workspace change and focus change
        if echo "$line" | grep -q '"change": "focus"'; then
            echo "[DEBUG] Workspace changed, processing focus and signal logic..."
            check_focus_and_signal
        fi
    done

    # If swaymsg exits or breaks, sleep briefly and restart
    echo "[DEBUG] swaymsg exited — restarting listener in 0.5 seconds..."
    sleep 0.5
done
