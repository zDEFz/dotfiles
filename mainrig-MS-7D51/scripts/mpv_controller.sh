#!/bin/bash

SOCKET_DIR="/tmp/mpvsockets"
CONTROL_FIFO="/tmp/mpv_controller_fifo"

# Make sure socat is installed
command -v socat >/dev/null 2>&1 || {
  echo "ERROR: socat not found. Please install it (e.g. apt install socat)." >&2
  exit 1
}

# Function to get all valid mpv sockets
get_all_sockets() {
  local sockets=()
  
  for i in {1..99}; do
    local socket_path="$SOCKET_DIR/mpvfloat$i"
    if [[ -S "$socket_path" ]]; then
      sockets+=("$socket_path")
    fi
  done
  
  echo "${sockets[@]}"
}

# Function to check if an mpv instance is playing or paused
is_playing() {
  local socket="$1"
  local result=$(echo '{ "command": ["get_property", "pause"] }' | socat - "$socket" 2>/dev/null)
  
  if [[ "$result" == *"data"* ]]; then
    local pause_status=$(echo "$result" | grep -o '"data":[a-z]*' | cut -d: -f2)
    if [[ "$pause_status" == "false" ]]; then
      return 0  # Playing
    fi
  fi
  
  return 1  # Not playing
}

# Function to get current playback time of an instance
get_playback_time() {
  local socket="$1"
  local result=$(echo '{ "command": ["get_property", "time-pos"] }' | socat - "$socket" 2>/dev/null)
  
  if [[ "$result" == *"data"* ]]; then
    local time=$(echo "$result" | grep -o '"data":[0-9.-]*' | cut -d: -f2)
    echo "$time"
  else
    echo "-1"
  fi
}

# Function to get the filename currently playing
get_filename() {
  local socket="$1"
  local result=$(echo '{ "command": ["get_property", "filename"] }' | socat - "$socket" 2>/dev/null)
  
  if [[ "$result" == *"data"* ]]; then
    local filename=$(echo "$result" | grep -o '"data":"[^"]*' | cut -d'"' -f4)
    echo "$filename"
  else
    echo "unknown"
  fi
}

# Function to detect newly playing instances by comparing timestamps
detect_newly_playing() {
  local prev_states="$1"
  local sockets=($2)
  local newly_playing=""
  local already_playing_count=0
  
  # First, count how many instances are currently playing
  for socket in "${sockets[@]}"; do
    if is_playing "$socket"; then
      already_playing_count=$((already_playing_count + 1))
      # If more than one is playing, don't try to be smart about newly playing
      if [[ $already_playing_count -gt 1 ]]; then
        # Return empty - let the calling function handle multiple players
        return 0
      fi
    fi
  done
  
  # If we only have one playing, proceed with detection
  for socket in "${sockets[@]}"; do
    local socket_name=$(basename "$socket")
    local is_currently_playing=$(is_playing "$socket" && echo "1" || echo "0")
    
    if [[ "$is_currently_playing" == "1" ]]; then
      local current_time=$(get_playback_time "$socket")
      local prev_line=$(echo "$prev_states" | grep "^$socket_name:")
      local prev_time=$(echo "$prev_line" | cut -d: -f2)
      
      if [[ -z "$prev_line" ]]; then
        # This instance wasn't playing before
        newly_playing="$socket"
        break
      fi
      
      # If playback position decreased substantially (restart or new track)
      # or if it increased by more than 5 seconds (skip/seek)
      if [[ -n "$prev_time" ]]; then
        if (( $(echo "$current_time < $prev_time - 1" | bc -l) )) || 
           (( $(echo "$current_time > $prev_time + 5" | bc -l) )); then
          newly_playing="$socket"
          break
        fi
      fi
    fi
  done

  echo "$newly_playing"
}

# Function to pause all instances except the one specified
pause_others() {
  local active_socket="$1"
  local sockets=($2)
  
  local active_name=$(basename "$active_socket")
  local active_file=$(get_filename "$active_socket")
  
  echo "New playback detected: $active_name ($active_file)"

  # Lock file to prevent rapid toggling/loops
  local lock_file="/tmp/mpv_pause_others_lock"
  local current_time=$(date +%s)
  
  # Check if we've recently paused instances (within 3 seconds)
  if [[ -f "$lock_file" ]]; then
    local lock_time=$(stat -c %Y "$lock_file" 2>/dev/null || echo 0)
    if (( current_time - lock_time < 3 )); then
      echo "Recently paused other instances, skipping to prevent pause loop"
      return 0
    fi
  fi
  
  # Create/update lock file
  touch "$lock_file"
  
  for socket in "${sockets[@]}"; do
    if [[ "$socket" != "$active_socket" && -S "$socket" ]]; then
      local socket_name=$(basename "$socket")
      if is_playing "$socket"; then
        # Add a socket-specific lock to prevent toggling loop
        touch "/tmp/mpv_pause_lock_$(basename "$socket")"
        
        echo "Pausing: $socket_name"
        echo '{ "command": ["set_property", "pause", true] }' | socat - "$socket" 2>/dev/null
      fi
    fi
  done
}

# Function to get the most recently used socket or the one the user interacted with last
get_active_socket() {
  local sockets=($1)
  local last_focused_file="/tmp/mpv_last_focused"
  local most_recently_used=""
  local last_modified_time=-1
  local playing_socket=""
  
  # PRIORITY 1: First check for any currently playing socket - this should be highest priority
  for socket in "${sockets[@]}"; do
    if is_playing "$socket"; then
      playing_socket="$socket"
      echo "$socket" > "$last_focused_file"
      echo "$socket"
      return 0
    fi
  done
  
  # PRIORITY 2: Check if we have a record of the last focused socket
  if [[ -f "$last_focused_file" ]]; then
    local last_socket=$(cat "$last_focused_file")
    
    # If this socket still exists, use it
    if [[ -S "$last_socket" ]]; then
      echo "$last_socket"
      return 0
    fi
  fi
  
  # PRIORITY 3: Find the most recently modified socket file (most likely to be the one in use)
  for socket in "${sockets[@]}"; do
    if [[ -S "$socket" ]]; then
      # Check socket mod time
      local mod_time=$(stat -c %Y "$socket" 2>/dev/null || echo 0)
      if (( mod_time > last_modified_time )); then
        last_modified_time=$mod_time
        most_recently_used=$socket
      fi
    fi
  done
  
  # If we found a recently modified socket, save and return it
  if [[ -n "$most_recently_used" ]]; then
    echo "$most_recently_used" > "$last_focused_file"
    echo "$most_recently_used"
    return 0
  fi
  
  # Last resort: any valid socket
  for socket in "${sockets[@]}"; do
    if [[ -S "$socket" ]]; then
      echo "$socket" > "$last_focused_file"
      echo "$socket"
      return 0
    fi
  done
  
  echo ""
  return 1
}

# Function to control the active mpv instance
control_playback() {
  local command="$1"
  local target_socket="$2"  # Optional specific socket parameter
  local all_sockets=($(get_all_sockets))
  local active_socket=""
  
  # List all available sockets for debugging
  echo "Available sockets:"
  for s in "${all_sockets[@]}"; do
    local s_name=$(basename "$s")
    local is_play=$(is_playing "$s" && echo "PLAYING" || echo "paused")
    local f_name=$(get_filename "$s")
    echo "  - $s_name: $is_play - $f_name"
  done
  
  # Determine which socket to use
  if [[ -n "$target_socket" && -S "$target_socket" ]]; then
    # Use the specified socket if provided
    active_socket="$target_socket"
    echo "Using specified socket: $active_socket"
  else
    # Otherwise get the active socket
    active_socket=$(get_active_socket "$(echo ${all_sockets[*]})")
  fi
  
  if [[ -z "$active_socket" ]]; then
    echo "No active mpv instance found."
    return 1
  fi
  
  # Save this as the last focused socket
  echo "$active_socket" > "/tmp/mpv_last_focused"
  
  local socket_name=$(basename "$active_socket")
  local current_file=$(get_filename "$active_socket")
  
  echo "Selected instance: $socket_name - $current_file"
  
  case "$command" in
    pause)
      echo "Toggling pause on $socket_name ($current_file)"
      # First check the current pause state
      local is_paused=$(echo '{ "command": ["get_property", "pause"] }' | socat - "$active_socket" 2>/dev/null)
      # Extract the boolean value
      local pause_status=$(echo "$is_paused" | grep -o '"data":[a-z]*' | cut -d: -f2)
      
      # Add a lock file to prevent rapid toggling
      local lock_file="/tmp/mpv_pause_lock_$(basename "$active_socket")"
      
      # Check if we recently toggled this instance (within 1 second)
      if [[ -f "$lock_file" ]]; then
        local lock_time=$(stat -c %Y "$lock_file" 2>/dev/null || echo 0)
        local current_time=$(date +%s)
        if (( current_time - lock_time < 1 )); then
          echo "Pause command for $socket_name ignored - too soon after previous toggle"
          return 0
        fi
      fi
      
      # Create/update lock file
      touch "$lock_file"
      
      if [[ "$pause_status" == "true" ]]; then
        # Currently paused, so unpause (force unpause with direct property setting)
        echo '{ "command": ["set_property", "pause", false] }' | socat - "$active_socket" 2>/dev/null
        echo "Unpaused $socket_name"
      else
        # Currently playing, so pause
        echo '{ "command": ["set_property", "pause", true] }' | socat - "$active_socket" 2>/dev/null
        echo "Paused $socket_name"
      fi
      
      # Clean up old lock files after 5 minutes
      find /tmp -name "mpv_pause_lock_*" -type f -mmin +5 -delete 2>/dev/null &
      ;;
    stop)
      echo "Stopping $socket_name ($current_file)"
      echo '{ "command": ["stop"] }' | socat - "$active_socket" 2>/dev/null
      ;;
    next)
      echo "Skipping to next track on $socket_name"
      echo '{ "command": ["playlist-next"] }' | socat - "$active_socket" 2>/dev/null
      
      ;;
    prev)
      echo "Going to previous track on $socket_name"
      echo '{ "command": ["playlist-prev"] }' | socat - "$active_socket" 2>/dev/null
      ;;
    status)
      local time=$(get_playback_time "$active_socket")
      local state=$(is_playing "$active_socket" && echo "playing" || echo "paused")
      # Get playlist position
      local position=$(echo '{ "command": ["get_property", "playlist-pos"] }' | socat - "$active_socket" 2>/dev/null | grep -o '"data":[0-9]*' | cut -d: -f2)
      local count=$(echo '{ "command": ["get_property", "playlist-count"] }' | socat - "$active_socket" 2>/dev/null | grep -o '"data":[0-9]*' | cut -d: -f2)
      echo "Status: $socket_name ($current_file)"
      echo "State: $state"
      echo "Position: $position of $count"
      echo "Time: $time seconds"
      ;;
    *)
      echo "Unknown command: $command"
      echo "Available commands: pause, stop, next, prev, status"
      return 1
      ;;
  esac
  
  return 0
}

# Create a named pipe for controlling the script
setup_control_pipe() {
  # Remove the pipe if it exists
  if [[ -p "$CONTROL_FIFO" ]]; then
    rm "$CONTROL_FIFO"
  fi
  
  # Create the named pipe
  mkfifo "$CONTROL_FIFO"
  
  # Make sure it gets cleaned up on exit
  trap "rm -f $CONTROL_FIFO" EXIT
}

# Main function for monitoring
monitor_mpv() {
  echo "Monitoring mpv instances in $SOCKET_DIR..."
  echo "Control via: echo 'command' > $CONTROL_FIFO"
  echo "Available commands: pause, stop, next, prev, status, quit"
  
  # Make sure the socket directory exists
  mkdir -p "$SOCKET_DIR"
  
  # Set up the control pipe
  setup_control_pipe
  
  local playback_states=""
  
  # Start the control pipe reader in the background
  # This reads commands from the pipe and executes them
  {
    while true; do
      if read -r command < "$CONTROL_FIFO"; then
        echo "Received command: $command"
        
        # Fixed: Better parsing of commands with instance numbers
        if [[ "$command" =~ ^pause([0-9]+)$ ]]; then
          # Get the exact instance number
          local instance_num="${BASH_REMATCH[1]}"
          
          # Find the specific socket
          local target=""
          for socket in $(get_all_sockets); do
            if [[ "$(basename "$socket")" == "mpvfloat$instance_num" ]]; then
              target="$socket"
              break
            fi
          done
          
          if [[ -n "$target" ]]; then
            echo "Targeting specific instance: mpvfloat$instance_num"
            control_playback "pause" "$target"
          else
            echo "Socket mpvfloat$instance_num not found"
          fi
        elif [[ "$command" == "quit" ]]; then
          echo "Quitting..."
          # Send a signal to the parent process to quit
          kill -TERM $$
          break
        elif [[ "$command" =~ ^(pause|stop|next|prev|status)$ ]]; then
          # Handle basic commands
          control_playback "$command"
        elif [[ "$command" =~ ^(pause|stop|next|prev|status):(.+)$ ]]; then
          # Handle commands with specific socket in format command:socketname
          local cmd_part="${BASH_REMATCH[1]}"
          local socket_part="${BASH_REMATCH[2]}"
          
          # Find the matching socket
          local target=""
          for socket in $(get_all_sockets); do
            if [[ "$(basename "$socket")" == "$socket_part" ]]; then
              target="$socket"
              break
            fi
          done
          
          if [[ -n "$target" ]]; then
            echo "Targeting specific instance: $socket_part"
            control_playback "$cmd_part" "$target"
          else
            echo "Socket $socket_part not found"
            control_playback "$cmd_part"
          fi
        elif [[ "$command" == "save" ]]; then
          # Save which socket is currently playing
          local playing=""
          for socket in $(get_all_sockets); do
            if is_playing "$socket"; then
              playing="$socket"
              break
            fi
          done
          
          if [[ -n "$playing" ]]; then
            echo "$(basename "$playing")" > "/tmp/mpv_last_focused"
            echo "Saved $(basename "$playing") as focused instance"
          else
            echo "No playing instance found to save"
          fi
        elif [[ "$command" == "list" ]]; then
          # List all instances
          echo "Available mpv instances:"
          local all_socks=($(get_all_sockets))
          for s in "${all_socks[@]}"; do
            local s_name=$(basename "$s")
            local is_play=$(is_playing "$s" && echo "PLAYING" || echo "paused")
            local f_name=$(get_filename "$s")
            echo "  - $s_name: $is_play - $f_name"
          done
        else
          echo "Unknown command: $command"
          echo "Available commands: pause, pause[N], stop, next, prev, status, list, save, quit"
        fi
      fi
    done
  } &
  local pipe_reader_pid=$!
  
  # Make sure to kill the pipe reader when the script exits
  trap "kill $pipe_reader_pid 2>/dev/null; rm -f $CONTROL_FIFO" EXIT
  
  # Main monitoring loop
  while true; do
    # Get all available sockets
    local all_sockets=($(get_all_sockets))
    
    if [[ ${#all_sockets[@]} -eq 0 ]]; then
      sleep 1
      continue
    fi
    
    # Update state for all sockets
    local new_states=""
    for socket in "${all_sockets[@]}"; do
      local socket_name=$(basename "$socket")
      if is_playing "$socket"; then
        local current_time=$(get_playback_time "$socket")
        new_states+="$socket_name:$current_time"$'\n'
      fi
    done
    
    # Check if any instance has started playing
    local newly_playing=$(detect_newly_playing "$playback_states" "$(echo ${all_sockets[*]})")
    
    if [[ -n "$newly_playing" ]]; then
      pause_others "$newly_playing" "$(echo ${all_sockets[*]})"
    fi
    
    # Update the stored states
    playback_states="$new_states"
    
    # Short sleep to avoid high CPU usage
    sleep 0.25
  done
}

# Function to check if the control pipe exists and the monitor is running
is_monitor_running() {
  if [[ ! -p "$CONTROL_FIFO" ]]; then
    return 1  # Control pipe doesn't exist, monitor not running
  fi
  
  # Try to write to the pipe to see if it's being read
  if ! echo "status" > "$CONTROL_FIFO" 2>/dev/null; then
    return 1  # Failed to write to pipe, monitor not running
  fi
  
  return 0  # Monitor is running
}

# Show help
show_help() {
  echo "Usage: $0 [command]"
  echo ""
  echo "Commands:"
  echo "  monitor        Start monitoring mpv instances (default if no command specified)"
  echo "  pause          Toggle pause on the currently active mpv instance"
  echo "  pause:NAME     Toggle pause on a specific instance (e.g. pause:mpvfloat19)"
  echo "  pause[N]       Toggle pause on mpvfloatN (e.g. pause13 for mpvfloat13)"
  echo "  stop           Stop the currently active mpv instance"
  echo "  next           Skip to the next track in the currently active mpv instance"
  echo "  prev           Go to the previous track in the currently active mpv instance"
  echo "  status         Show the status of the currently active mpv instance"
  echo "  list           List all active mpv instances"
  echo "  save           Remember the current playing instance for future commands"
  echo "  quit           Stop the monitoring process"
  echo ""
  echo "When running, use: echo 'command' > $CONTROL_FIFO"
  echo "Example: echo 'next' > $CONTROL_FIFO"
  echo "Example: echo 'pause13' > $CONTROL_FIFO to pause mpvfloat13"
  echo "Example: echo 'pause:mpvfloat19' > $CONTROL_FIFO"
  echo ""
}

# Main script execution
if [[ $# -eq 0 ]]; then
  # No arguments, default to monitor mode
  monitor_mpv
else
  case "$1" in
    monitor)
      monitor_mpv
      ;;
    pause|stop|next|prev|status|list|quit)
      if is_monitor_running; then
        # Send command to the running monitor
        echo "$1" > "$CONTROL_FIFO"
      else
        # If monitor is not running, handle the command directly or start monitor
        if [[ "$1" == "quit" ]]; then
          echo "Monitor is not running."
        else
          echo "Monitor is not running. Starting monitor..."
          monitor_mpv
        fi
      fi
      ;;
    pause[0-9]*)
      # Handle pause with instance number
      if is_monitor_running; then
        echo "$1" > "$CONTROL_FIFO"
      else
        echo "Monitor is not running. Starting monitor..."
        monitor_mpv
      fi
      ;;
    help|-h|--help)
      show_help
      ;;
    *)
      echo "Unknown command: $1"
      show_help
      exit 1
      ;;
  esac
fi
