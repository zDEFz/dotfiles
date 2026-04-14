#!/bin/bash

# --- CATEGORY: APPLICATIONS ---

# menu: Applications | 🔪 Kill/Close Cultris II
app_cultris_kill() {
    pkill -9 -f cultris2.jar && notify-send "Cultris II" "Terminated" || notify-send "Cultris II" "Not running"
}

# menu: Applications | 🔪 Kill/Close VS Code
app_vscode_kill() {
    pkill -9 -f "code" && notify-send "VS Code" "Terminated" || notify-send "VS Code" "Not running"
}

# menu: Applications | 📄 Open wofi snd_file_player playlists
app_sndfile_playlists_wofi() {
	bash ~/scripts/sndfile_player/lua/snd_file_player_lua.sh
}

# menu: Applications | 🗑️ Kill/Close wofi snd_file_player playlists
app_sndfile_playlists_wofi_close() {
	pkill -9 -f "snd_file_player"
	pkill -9 -f "luajit"
	killall -9 sndfile-play 2>/dev/null
}

# menu: Applications | 🎵 Create MPV Workspace
app_mpv_workspace_setup() {
	bash ~/scripts/mpv/playlist_to_mini_mpv_windows/main_script.sh
}

# menu: Applications | 🎵 Open MPV media watch
app_mpv_open_media_watch() {
	bash ~/scripts/mpv/media_watch/main_script.sh
}

# menu: Applications | 🗑️ Kill/Close MPV Workspace
app_mpv_workspace_kill() {
    # Flag to track if we found any processes to kill
    local found_processes=false

    # 1. Send SIGTERM to players
    if pkill -15 -f "openmusic|mpvfloat"; then
        found_processes=true
    fi
    
    # 2. Kill helper scripts (Removed extensions for better matching)
    if pkill -9 -f "realign_opemusic|mpv_controller|mpv_ipc_pause_others"; then
        found_processes=true
    fi

    # 3. Wait for disk I/O
    sleep 0.5
        
    # 4. Force kill hanging players
    if pkill -9 -f "openmusic|mpvfloat"; then
        found_processes=true
    fi

    # 5. Cleanup filesystem artifacts
    rm -f /dev/shm/mpvsockets/mpvfloat*
    rm -rf /dev/shm/mpv_monitor_cache/*

    # Final Feedback Message
    if [ "$found_processes" = true ]; then
        notify-send "MPV" "Session Forcefully Terminated"
    else
        notify-send "MPV" "No active processes found to kill"
        echo "No matching processes were running."
    fi
}

# menu: Applications | 🎮 Launch Slippi (RAM)
app_slippi_ram_setup() {
     alacritty -e bash -lc "/home/blu/apps/slippi/slippi_to_ram.sh"
}

# menu: Applications | 🎮 Launch Slippi (Normal)
app_slipp() { 
	~/apps/slippi
}




# Only run dispatcher if executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
