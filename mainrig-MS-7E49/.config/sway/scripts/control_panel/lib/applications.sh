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

# menu: Applications | 🎵 Create MPV Workspace
app_mpv_workspace_setup() {
	bash /home/blu/scripts/mpv/openmusic
}

# menu: Applications | 🗑️ Kill/Close MPV Workspace
app_mpv_workspace_kill() {
    # Stop the background controller scripts (Force kill by filename)
	pkill -9 -f "openmusic"
	pkill -9 -f "realign_opemusic.bash"
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

# menu: Applications | 🎮 Launch Slippi (RAM)
app_slippi_ram_setup() {
    # 1. Kill any existing slow instances
    killall -9 slippi-launcher Slippi.AppImage 2>/dev/null

    # 2. Path Definitions
    local LAUNCH_DIR="/tmp/slippi-test"
    local DOLPHIN_RAM="/tmp/slippi-dolphin-ram"
    local ISO_RAM="/tmp/melee-ram.iso"

    local ORIGINAL_APP="$HOME/apps/slippi/Slippi.AppImage"
    local NETPLAY_DIR="$HOME/.config/chromium/netplay"
    local AKANEIA_ISO="$HOME/.local/share/dolphin-emu/Games/Smash_Bros_Melee_Akaneia_1_0_1.iso"

    echo "🚀 Initializing RAM environment..."

    # 3. Extract Launcher to RAM (if needed)
    if [ ! -d "$LAUNCH_DIR" ]; then
        echo "📦 Extracting Launcher to RAM..."
        mkdir -p "$LAUNCH_DIR"
        (cd /tmp && "$ORIGINAL_APP" --appimage-extract > /dev/null && mv squashfs-root/* "$LAUNCH_DIR/" && rm -rf squashfs-root)
    fi

    # 4. Extract Dolphin Engine to RAM (if needed)
    if [ ! -d "$DOLPHIN_RAM" ]; then
        echo "🐬 Extracting Dolphin Engine to RAM..."
        mkdir -p "$DOLPHIN_RAM"
        local DOLPHIN_SRC=$(find "$HOME/.config" -name "Slippi_Online-x86_64.AppImage" | head -n 1)
        if [ -n "$DOLPHIN_SRC" ]; then
            (cd /tmp && "$DOLPHIN_SRC" --appimage-extract > /dev/null && mv squashfs-root/* "$DOLPHIN_RAM/" && rm -rf squashfs-root)
        fi
    fi

    # 5. Move Melee ISO to RAM
    if [ ! -f "$ISO_RAM" ]; then
        echo "💿 Copying ISO to RAM..."
        cp "$AKANEIA_ISO" "$ISO_RAM"
    fi

    # 6. The Binary Swap Trick (Instant 'Play' button)
    echo "⚡ Injecting RAM-redirector for Dolphin..."
    mkdir -p "$NETPLAY_DIR"
    cat <<EOF > "$NETPLAY_DIR/Slippi_Online-x86_64.AppImage"
export LD_LIBRARY_PATH="$DOLPHIN_RAM/usr/lib/:$DOLPHIN_RAM/usr/lib/x86_64-linux-gnu/:\$LD_LIBRARY_PATH"
exec "$DOLPHIN_RAM/AppRun" "\$@"
EOF
    chmod +x "$NETPLAY_DIR/Slippi_Online-x86_64.AppImage"

    # 7. Final Launch (Using Test 3 "Golden" logic)
    echo "⚡ Launching Slippi (RAM Mode)..."
    export APPDIR="$LAUNCH_DIR"
    export LD_LIBRARY_PATH="$LAUNCH_DIR/usr/lib/:$LAUNCH_DIR/usr/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH"
    export XDG_CONFIG_HOME="$HOME/.config"

    cd "$LAUNCH_DIR"
    nohup ./slippi-launcher \
        --no-sandbox \
        --disable-gpu-sandbox \
        --ignore-gpu-blocklist \
        --user-data-dir="$HOME/.config/chromium" >/dev/null 2>&1 &

    disown
    echo "🏁 DONE. All systems in RAM."
}


"$@"
