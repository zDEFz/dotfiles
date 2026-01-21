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
    # Stop the background controller scripts (Force kill by filename)
    pkill -9 -f "mpv_controller.bash"
    pkill -9 -f "mpv_ipc_pause_others.bash"
    
    # Kill all mpv instances using the 'mpvfloat' app_id/socket name
    pkill -9 -f "mpvfloat"
        
    # Delete stale IPC socket files to prevent script hang on restart
    rm -f /tmp/mpvsockets/mpvfloat*

    # Wipe cached state and snapshots
    rm -rf /tmp/mpv_monitor_cache/*

    # On-screen confirmation that everything is closed
    notify-send "MPV" "Controller and Players Terminated"
}


"$@"
