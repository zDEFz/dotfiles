#!/bin/bash

# --- CATEGORY: APPLICATIONS ---
# menu: Applications | 🔪 Kill Cultris II
app_cultris_kill() {
    pkill -9 -f cultris2.jar && notify-send "Cultris II" "Terminated" || notify-send "Cultris II" "Not running"
}

# menu: Applications | 🔪 Kill VS Code
app_vscode_kill() {
    pkill -9 -f "code" && notify-send "VS Code" "Terminated" || notify-send "VS Code" "Not running"
}
# menu: Applications | 🎵 Create MPV Workspace
app_mpv_workspace_setup() {
	bash /home/blu/scripts/openmusic
}

# menu: Applications | 🗑️ Kill/Close MPV Workspace
app_mpv_workspace_kill() {
    # Specifically target the controller script path
    # Using pkill -f allows matching the full command line seen in btop
    pkill -9 -f "mpv_controller.bash"
    
    # Kill the mpv players
    pkill -9 -f "mpvfloat"
    
    notify-send "MPV" "Controller and Players Terminated"
}


"$@"
