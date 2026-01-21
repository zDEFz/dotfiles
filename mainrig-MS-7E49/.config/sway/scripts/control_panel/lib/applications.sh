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

# menu: Applications | 🎮 Launch Slippi (Max Performance)
app_slippi_ram_setup() {
    local launcher_ram="/tmp/slippi-ram"
    local dolphin_ram="/tmp/slippi-dolphin"
    local launcher_app="$HOME/apps/slippi/Slippi.AppImage"
    local config_dir="$HOME/.config/Slippi Launcher"
    local dolphin_app="$config_dir/netplay/Slippi_Online-x86_64.AppImage"

    # 1. Extract Launcher to RAM
    if [ ! -d "$launcher_ram" ]; then
        echo "🚀 Extracting Launcher to RAM..."
        mkdir -p "$launcher_ram"
        (cd /tmp && "$launcher_app" --appimage-extract > /dev/null && mv squashfs-root/* "$launcher_ram/" && rm -rf squashfs-root)
    fi

    # 2. Extract the actual Emulator (Dolphin) to RAM
    # This is what makes the 'Play' button instant
    if [ ! -d "$dolphin_ram" ]; then
        echo "🐬 Extracting Dolphin Emulator to RAM..."
        mkdir -p "$dolphin_ram"
        (cd /tmp && "$dolphin_app" --appimage-extract > /dev/null && mv squashfs-root/* "$dolphin_ram/" && rm -rf squashfs-root)
    fi

    # 3. Create a Symlink so the Launcher finds the RAM-Dolphin instead of the SSD one
    # We back up the original netplay folder first
    if [ ! -L "$config_dir/netplay" ]; then
        [ -d "$config_dir/netplay" ] && mv "$config_dir/netplay" "$config_dir/netplay.bak"
        ln -s "$dolphin_ram" "$config_dir/netplay"
    fi

    echo "⚡ Launching Slippi (All systems in RAM)..."
    
    # Launch with Wayland flags since you are on Sway
    "$launcher_ram/AppRun" --enable-features=UseOzonePlatform --ozone-platform=wayland & disown
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
