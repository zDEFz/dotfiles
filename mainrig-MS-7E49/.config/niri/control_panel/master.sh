#!/bin/bash

# ==================================================
# MERGED LIBRARY FOR ARCHITECTURAL REVIEW
# ==================================================


# --- FROM FILE: helpers.sh ---

# --- CATEGORY: HELPERS ---
# Internal helper used for moving containers to specific outputs
_open_local_service() {
    local path="$1"
    local proto="${2:-https}" 
    _firefox_open_url "${proto}://$(hostname)/${path}"
}

_firefox_open_url() {
    firefox --no-remote -P "firefox-default" --class "firefox-default" --name "firefox-default" "$1"
}

_rdp_connect() {
    local host="$1"
    local user="$2"
    local pass="$3"

    echo "Connecting to $host..."
	
    wlfreerdp \
        /u:"$user" \
        /p:"$pass" \
        /v:"$host" \
        /cert:ignore \
        +clipboard \
        /dynamic-resolution \
        /drive:home,"$HOME"
}

_win_move_to_output() { 
    swaymsg move container to output "'${!1}'"
}



# --- FROM FILE: applications.sh ---

# --- CATEGORY: APPLICATIONS ---

# menu: Applications | 🔪 Kill/Close Cultris II
app_cultris_kill() {
    pkill -9 -f cultris2.jar && notify-send "Cultris II" "Terminated" || notify-send "Cultris II" "Not running"
}

# menu: Applications | 🔪 Kill/Close VS Code
app_vscode_kill() {
    pkill -9 -f "code" && notify-send "VS Code" "Terminated" || notify-send "VS Code" "Not running"
}

# menu: Applications | wofi mpv playlists
app_mpv_playlists_wofi() {
	bash ~/scripts/mpv/mpv_playlists_wofi/mpv_playlists_wofi.sh
}

# menu: Applications | Kill/Close wofi mpv playlists
app_mpv_playlists_wofi_close() {
    local pid_file="/dev/shm/mpv_wofi_playlist.pid"

    if [ -f "$pid_file" ]; then
        local target_pgid=$(cat "$pid_file")
        
        # KILL LOGIC:
        # We send SIGKILL (-9) to the negative PGID (-$target_pgid).
        # This nukes the script, the fd process, and the mpv process simultaneously.
        kill -9 -"$target_pgid" 2>/dev/null
        
        rm -f "$pid_file"
        notify-send "MPV Playlists" "Session $target_pgid Stopped"
    else
        notify-send "MPV Playlists" "No active session found"
    fi
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




# --- FROM FILE: browse.sh ---

# menu: Browse | 📂 Open Anime Shows Folder
browse_anime_shows_folder() {
	dbus-launch thunar --name Thunar-Animeshows '/mnt/storage/anime/anime-shows'
}

# menu: Browse | 📂 Open Anime Movies Folder
browse_anime_movies_folder() {
	dbus-launch thunar --name Thunar-Animemovies '/mnt/storage/anime/anime-movies'
}

# menu: Browse | 📚 Browse Manga
browse_manga() {
	_open_local_service "manga/"
}




# --- FROM FILE: clipboard_services.sh ---

# menu: Clipboard Services | 📎 x0pipeclip
clipboard_to_x0() {
    source /home/blu/scripts/functions/paste_services
    x0pipeclip "$(wl-paste)"
}




# --- FROM FILE: dev_env.sh ---

# --- CATEGORY: DEV ENVIRONMENT ---

# menu: Dev Env | 📂 Sway Control Panel VSCode
dev_sway_config_control_panel_vscode() {
	code "$HOME/.config/sway/scripts/control_panel/"
}

# menu: Dev Env | 📂 Sway Config VSCode
dev_sway_config_vscode() {
	code "$HOME/.config/sway/"
}

# menu: Dev Env | 🧪 Config Sync Git Repos AI
dev_update_git_repos_ai() { 
	code "$HOME/scripts/cronjobs/update_repos_ai"
}

# menu: Dev Env | 🧪 scratchpad git commit vscode ram
dev_scratchpad_vscode_ram() {
	bash "$HOME/scripts/git/scratchpad_git_commit_vscode_ram.sh"
}




# --- FROM FILE: dev_env_special.sh ---
# menu: Dev Env Special| 💻 Cultris Alacritty
dev_cultris_shell() {
	alacritty \
		--config-file "$HOME/.config/alacritty/alacritty.toml" \
		--class alacritty_floating \
		--title "Cultris Dev Env" \
		--working-directory "$HOME/git/c2-patch-deobf" \
		-e $SHELL
}

# menu: Dev Env Special | 📝 Cultris VSCode
dev_cultris_vscode() {
	local DISK_SRC="$HOME/git/c2-patch-deobf"
	local RAM_ROOT="/dev/shm/cultris-dev"
	local DATA_DIR="/dev/shm/.vscode-c2-dev"
	local LOCK_FILE="/dev/shm/cultris.lock"

	mkdir -p "$RAM_ROOT"
	mkdir -p "$DATA_DIR/User"
	touch "$LOCK_FILE"

	rsync -av --delete "$DISK_SRC/" "$RAM_ROOT/"

	local J_BASE="$RAM_ROOT/resources/jdk-17.0.13+11/bin"
	local CP="$RAM_ROOT/binary:$RAM_ROOT/resources/libs/*"
	local MAIN_CLASS="net.gewaltig.cultris.Cultris"

	local REFRESH_CMD="unsetopt histchars 2>/dev/null || true; fuser -k -9 $LOCK_FILE 2>/dev/null || true; $J_BASE/javac -cp '$CP' -sourcepath $RAM_ROOT/binary -d $RAM_ROOT/binary $RAM_ROOT/binary/Mapping.java $RAM_ROOT/binary/*.java \${file} && ($J_BASE/java -Djava.library.path='$RAM_ROOT/resources/libs' -cp '$CP' $MAIN_CLASS & disown) && echo 'REFRESHED'"
	local SAVE_CMD="rsync -av --exclude='resources/' '$RAM_ROOT/' '$DISK_SRC/' && cd '$DISK_SRC/binary' && rm -f ../cultris2.jar && zip -r -9 ../cultris2.jar * -x '*.j' && echo 'DISK UPDATED & JAR REPACKED'"
	local REVERT_CMD="cd '$DISK_SRC' && git checkout HEAD -- . ':!resources' && git clean -fd -e resources/ && rsync -av --delete '$DISK_SRC/' '$RAM_ROOT/' && find '$RAM_ROOT/binary' -type f -name '*.java' -exec touch -m {} + && echo 'REVERTED: Resources preserved.'"

	local G_STATUS="cd '$DISK_SRC' && echo '--- GIT STATUS ---' && git status"
	local G_DIFF="cd '$DISK_SRC' && echo '--- GIT DIFF ---' && git diff"
	local G_PUSH="cd '$DISK_SRC' && echo '--- PUSHING TO REMOTE ---' && git push"
	local G_COMMIT="cd '$DISK_SRC' && git add . && printf 'Enter commit message: ' && read msg && git commit -m \\\"\$msg\\\""

	cat >"$DATA_DIR/User/settings.json" <<EOF
{
    "runOnSave.enabled": true,
    "runOnSave.commands": [{
        "match": ".*\\\\.java$",
        "command": "$REFRESH_CMD",
        "runIn": "terminal"
    }],
    "files.autoSave": "off",
    "actionButtons": {
        "commands": [
            { "name": "⬆️ PUSH", "command": "$G_PUSH", "color": "#1abc9c" },
            { "name": "💾 SYNC & JAR", "command": "$SAVE_CMD", "color": "#4caf50" },
            { "name": "📊 STATUS", "command": "$G_STATUS", "color": "#3498db" },
            { "name": "📦 COMMIT", "command": "$G_COMMIT", "color": "#e67e22" },
            { "name": "🔄 REVERT", "command": "$REVERT_CMD", "color": "#ffcc00" },
            { "name": "🔍 DIFF", "command": "$G_DIFF", "color": "#9b59b6" },
            { "name": "🚀 REFRESH", "command": "$REFRESH_CMD", "color": "#ff4500" }
        ]
    }
}
EOF

	code --user-data-dir "$DATA_DIR" "$RAM_ROOT"
}

# --- FROM FILE: display_controls.sh ---

# --- CATEGORY: DISPLAY CONTROLS ---
# Individual Controls

# menu: Display Controls | ✅ Emergency Power outage mode 
display_power_outage_mode() { 
	for d in "$L" "$R" "$LL" "$RR"; do swaymsg output "'$d'" disable; done; 
}

# menu: Display Controls | ✅ Enable L
display_L_on() { swaymsg output "'$L'" enable; }

# menu: Display Controls | ❌ Disable L
display_L_off() { swaymsg output "'$L'" disable; }

# menu: Display Controls | ✅ Enable LL
display_LL_on() { swaymsg output "'$LL'" enable; }

# menu: Display Controls | ❌ Disable LL
display_LL_off() { swaymsg output "'$LL'" disable; }

# menu: Display Controls | ❌ Disable LL and Disable RR
display_LL_RR_off() { swaymsg output "'$LL'" disable; swaymsg output "'$RR'" disable; }

# menu: Display Controls | ✅ Enable LL and Enable RR
enable_LL_RR_on() { swaymsg output "'$LL'" enable; swaymsg output "'$RR'" enable; }

# menu: Display Controls | ✅ Enable M
display_M_on() { swaymsg output "'$M'" enable; }

# menu: Display Controls | ❌ Disable M
display_M_off() { swaymsg output "'$M'" disable; }

# menu: Display Controls | ✅ Enable MON_KB
display_MON_KB_on() { swaymsg output "'$MON_KB'" enable; }

# menu: Display Controls | ❌ Disable MON_KB
display_MON_KB_off() { swaymsg output "'$MON_KB'" disable; }

# menu: Display Controls | ✅ Enable R
display_R_on() { swaymsg output "'$R'" enable; }

# menu: Display Controls | ❌ Disable R
display_R_off() { swaymsg output "'$R'" disable; }

# menu: Display Controls | ❌ Disable L and Disable R
display_L_R_off() { swaymsg output "'$L'" disable; swaymsg output "'$R'" disable; }

# menu: Display Controls | ✅ Enable L and Enable R
enable_L_R_on() { swaymsg output "'$L'" enable; swaymsg output "'$R'" enable; }

# menu: Display Controls | ✅ Enable RR
display_RR_on() { swaymsg output "'$RR'" enable; }

# menu: Display Controls | ❌ Disable RR
display_RR_off() { swaymsg output "'$RR'" disable; }

# menu: Display Controls | ✅ Enable TAIKO
display_TAIKO_on() { swaymsg output "'$TAIKO'" enable; }

# menu: Display Controls | ❌ Disable TAIKO
display_TAIKO_off() { swaymsg output "'$TAIKO'" disable; }

# Group Controls
# menu: Display Controls | ❌ Disable support all
display_group_all_off() { for d in "$L" "$M" "$R" "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable all Seat Displays
display_group_seat_on() { for d in "$L" "$LL" "$M" "$MON_KB" "$R" "$RR"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | ❌ Disable all Seat Displays
display_group_seat_off() { for d in "$L" "$LL" "$M" "$MON_KB" "$R" "$RR"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | 🔄 Set refresh rate
display_set_hz() {
	source "$HOME/scripts/functions/video"
    local RATE
    
    if [[ -n "$1" ]]; then
        RATE="$1"
    else
        RATE=$(wofi --insensitive --dmenu -p "Hz")
    fi

    [[ -z "$RATE" ]] && return

    # We use a for loop with a subshell result
    # This is often more reliable than a pipe for simple string lists
    for i in $(lshz | grep -o "DP-[0-9]"); do
        swaymsg output "$i" resolution 1920x1080@"$RATE"Hz
    done
}




# --- FROM FILE: myanimelist.sh ---

# menu: MyAnimeList | 📺 MAL Synopsis from clipboard
app_mal_synopsis_clip() {
    "$USER_HOME"/.config/sway/scripts/myanimelist_coverart_search.sh "$(wl-paste)"
}




# --- FROM FILE: open_url.sh ---

# --- Core Nginx Services ---
# menu: Open URL | Open local Nginx Mainrig
open_url_nginx_mainrig()         { _open_local_service ""; }

# menu: Open URL | Open local food Mainrig
open_url_nginx_food_mainrig()     { _open_local_service "food/"; }

# menu: Open URL | Open local Nginx Backups
open_url_nginx_backups()         { _open_local_service "backups/"; }

# menu: Open URL | Open local Nginx Cronlogs
open_url_nginx_cronlogs()        { _open_local_service "cronlogs/"; }

# menu: Open URL | Open local Nginx Videov
open_url_nginx_video()		   { _open_local_service "video/"; }

# menu: Open URL | Open local Linux Kernel Development URL 
open_url_nginx_lkd()            { _open_local_service "linux_kernel/"; }

# menu: Open URL | Open local Explainshell
open_url_nginx_explainshell()    { _open_local_service "explainshell/"; }

# menu: Open URL | Open local Gitea 
open_url_nginx_gitea()          { _open_local_service "gitea/"; }

# --- Kiwix Documentation ---
# menu: Open URL | Open local ArchWiki
open_url_kiwix_archwiki()        { _open_local_service "kiwix/viewer#archlinux_en_all_maxi_2025-09/Main_page"; }

# menu: Open URL | Open local Wikipedia
open_url_kiwix_wikipedia()       { _open_local_service "kiwix/viewer#wikipedia_en_all_maxi_2025-08"; }

# menu: Open URL | Open local Japanese QA
open_url_kiwix_japanese_qa()     { _open_local_service "kiwix/viewer#japanese.stackexchange.com_mul_all_2025-12"; }

# --- Local Web Services (Now HTTPS) ---
# menu: Open URL | Open local Cyberchef
open_url_svc_cyberchef()         { _open_local_service "cyberchef/"; }

# menu: Open URL | Open local Audio Search
open_url_svc_audio_search()      { _open_local_service "audio/search_all/"; }

# menu: Open URL | Open local Shenzhen Solitaire
open_url_svc_solitaire()         { _open_local_service "shenzhen_solitaire/"; }

# --- External & Hardware ---
# menu: Open URL | Open local Fritzbox
open_url_ext_fritzbox()          { _firefox_open_url "http://fritz.box"; }

# menu: Open URL | Open local IPMI NAS
open_url_ext_ipmi_nas()          { _firefox_open_url "https://nas.ipmi/"; }

# menu: Open URL | Open local pi kvm
open_url_ext_pi_kvm()            { _firefox_open_url "https://kvm/"; }

# menu: Open URL | Open gitea.tail.ws Gitea 
open_url_nginx_gitea_tail_ws()   { _firefox_open_url "gitea.tail.ws/"; }




# --- FROM FILE: print.sh ---

# menu: Print | 📋 Print System Specs
sys_print_specs() {
    # 1. Generate clean text
    # -c none: ignores your local config file
    # -l none: removes the logo/ascii art
    # --pipe: outputs raw text without colors/escape codes
    local TEXT
    TEXT=$(fastfetch -c none -l none --pipe --structure OS:Host:Kernel:Uptime:Packages:CPU:GPU:Memory)

    # 2. Copy to clipboard
    echo -n "$TEXT" | wl-copy

    # 3. Paste with a slight delay for Wayland stability
    sleep 0.2
    echo 'key ctrl+v' | dotoolc
}



# --- FROM FILE: rdp.sh ---

# --- Execution Logic ---
# --- RDP Connections ---
# menu: RDP | RDP Connect to taiko-MS-7D51
rdp_connect_taiko_ms_7d51() {
	source /home/blu/.secure_env
    _rdp_connect "taiko-MS-7D51" "$taiko_MS_7D51_USER" "$taiko_MS_7D51_PWD"
}




# --- FROM FILE: system.sh ---

# --- CATEGORY: SYSTEM ---
# menu: System | 🚀 Start dotoold
# dotoold_manager.sh - Manages dotoold daemon
sys_dotoold_start() {
    pgrep -x dotoold >/dev/null || (nohup dotoold >/dev/null 2>&1 & echo "dotoold started")
}

# menu: System | 📜 Follow Journalctl
# system_functions.sh - System utilities
sys_journal_follow() {
    alacritty \
        --config-file="$USER_HOME/.config/alacritty/alacritty.toml" \
        --class alacritty_floating \
        --title "Floating Terminal" \
        --working-directory "$USER_HOME" \
        -e bash -c "sudo journalctl -f"
}



# --- FROM FILE: tetris_tools.sh ---

# menu: Tetris Tools | 🎵 Activate 1kf Sounds
1kf_sounds() { 
    local pid_file="/dev/shm/1kf_sounds.pid"

    if ! command -v play &> /dev/null || ! command -v libinput &> /dev/null; then
        echo "❌ Please install dependencies: sudo pacman -S sox libinput-tools"
        return 1
    fi

    echo "🚀 1kf Sound Orientation Active [Bulma's Spaceship Computer]"
    echo "📟 System Status: ONLINE"
    echo "🛡️ Boundary Guard: Enabled (Strict Matrix Only)"

    (
        declare -A FREQS=(
            [KEY_1]=400 [KEY_2]=444 [KEY_3]=488 [KEY_4]=533 [KEY_5]=577
            [KEY_6]=622 [KEY_7]=666 [KEY_8]=711 [KEY_9]=755 [KEY_0]=800
            [KEY_Q]=450 [KEY_W]=494 [KEY_E]=538 [KEY_R]=583 [KEY_T]=627
            [KEY_Y]=672 [KEY_U]=716 [KEY_I]=761 [KEY_O]=805 [KEY_P]=850
            [KEY_A]=500 [KEY_S]=544 [KEY_D]=588 [KEY_F]=633 [KEY_G]=677
            [KEY_H]=722 [KEY_J]=766 [KEY_K]=811 [KEY_L]=855 [KEY_SEMICOLON]=900
            [KEY_Z]=550 [KEY_X]=594 [KEY_C]=638 [KEY_V]=683 [KEY_B]=727
            [KEY_N]=772 [KEY_M]=816 [KEY_COMMA]=861 [KEY_DOT]=905 [KEY_SLASH]=950
        )

        RATE=22050
        BITS=16
        CHANNELS=1
        DURATION=0.055
        FADE_IN=0.003
        FADE_OUT=0.012

        libinput debug-events --show-keycodes | while read -r line; do
            if [[ "$line" == *"pressed"* ]]; then
                key=$(echo "$line" | grep -oP 'KEY_[A-Z0-9_]+')
                if [[ -n "$key" && -n "${FREQS[$key]}" ]]; then
                    freq="${FREQS[$key]}"
                    play -q -r $RATE -b $BITS -c $CHANNELS -n synth $DURATION sine "$freq" tremolo 8 40 fade t $FADE_IN $DURATION $FADE_OUT gain -8 echo 0.8 0.7 10 0.3 lowpass 6000 &
                elif [[ "$key" == "KEY_SPACE" ]]; then
                    play -q -r $RATE -b $BITS -c $CHANNELS -n synth 0.08 sine 500:600 fade t 0.005 0.08 0.02 gain -9 echo 0.8 0.7 12 0.3 lowpass 5000 &
                elif [[ "$key" == "KEY_RIGHTSHIFT" ]]; then
                    (play -q -r $RATE -b $BITS -c $CHANNELS -n synth 0.05 sine 1000 fade t 0.002 0.05 0.01 gain -9 echo 0.8 0.7 10 0.3 lowpass 6000 ; \
                     play -q -r $RATE -b $BITS -c $CHANNELS -n synth 0.05 sine 800 fade t 0.002 0.05 0.012 gain -9 echo 0.8 0.7 10 0.3 lowpass 6000) &
                fi
            fi
        done
    ) >/dev/null 2>&1 < /dev/null &  # Redirect EVERYTHING to null
    
    echo $! > "$pid_file"
	disown $!
}

# menu: Tetris Tools | 🔇 Stop 1kf Sounds
stop_1kf_sounds() {
    local pid_file="/dev/shm/1kf_sounds.pid"

    echo "🔌 Deactivating Spaceship Computer..."
    
    if [ -f "$pid_file" ]; then
        local saved_pid=$(cat "$pid_file")
        # Kill the subshell process and all children
        pkill -P "$saved_pid" 2>/dev/null
        kill "$saved_pid" 2>/dev/null
        rm "$pid_file"
    fi

    # Hard cleanup for libinput and audio
    pkill -f "libinput debug-events"
    pkill -u "$USER" play
    
    echo "💤 System Status: OFFLINE"
}




# --- FROM FILE: typing_tools.sh ---

# --- CATEGORY: TYPING TOOLS ---
# menu: Typing Tools | 📱 Type Phone plain
type_phone_plain() {
    TEXT=$(echo "$PERSONAL_PHONE" | sed 's/[^+0-9]//g')
    [ -n "$TEXT" ] && printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
}

# menu: Typing Tools | 📱 Type Phone plain without country code
type_phone_no_country() {
    TEXT=$(echo "$PERSONAL_PHONE" | sed 's/[^0-9]//g' | sed 's/^[0-9]\{1,2\}//')
    [ -n "$TEXT" ] && printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
}

# menu: Typing Tools | 📱 Type Phone formatted
type_phone_formatted() {
    TEXT="$PERSONAL_PHONE"
    [ -n "$TEXT" ] && printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
}

# menu: Typing Tools | 📋 Type clipboard
type_clipboard() {
    TEXT=$(wl-paste)
    [ -n "$TEXT" ] && printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
}

# menu: Typing Tools | 📅 Type date
type_date() { printf 'key leftctrl\ntype %s\n' "$(date --iso-8601)" | dotoolc; }

# menu: Typing Tools | 🏠 Type hostname
type_hostname() { printf 'key leftctrl\ntype %s\n' "$(hostname)/" | dotoolc; }

# menu: Typing Tools | 🌐 Type local ip
type_ip_local() {
    TEXT=$(ip addr show | grep -i 'inet 192' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
    printf 'key leftctrl\ntype %s\n' "$TEXT" | dotoolc
}

# menu: Typing Tools | 🔑 Type vmpwd
type_vmpwd() {
    [ -n "$vmpwd" ] && printf 'key leftctrl\ntype %s\nkey Tab\nkey space\nkey Tab\nkey space\n' "$vmpwd" | dotoolc
}

# menu: Typing Tools | 🔐 Type veracrypt pwd
type_veracrypt_pwd() {
    [ -n "$veracryptpwd" ] && printf 'typedelay 20\nkeydelay 20\ntype %s\nkey Enter\nkey Enter\n' "$veracryptpwd" | dotoolc
}




# --- FROM FILE: window_management.sh ---

# menu: Window Management | 🎯 Focus OpenTaiko
app_opentaiko_focus() { 
    swaymsg '[class="^(OpenTaiko|opentaiko.exe)$"] focus'
}

# menu: Window Management | 🎯 Focus MPV Workspace
win_focus_mpv_workspace() {
    # We search for mpvfloat instances and extract the workspace name
    local TARGET_WS=$(swaymsg -t get_tree | jq -r '.. | select(.type? == "workspace") | select(.floating_nodes? // [] | .[].app_id | test("mpvfloat")) | .name' | head -n 1)

    if [ -n "$TARGET_WS" ]; then
        swaymsg workspace "$TARGET_WS"
    else
        # Fallback to 18 if no mpvfloat is found
        swaymsg workspace 18
    fi
}

# menu: Window Management | 🎼 Focus Active MPV 🎵
win_mpv_focus_active() {
local socket_dir="/dev/shm/mpvsockets"
	local playing_id=""

	# 1. Find which one is playing (using your script's logic)
	for s in "$socket_dir"/mpvfloat*; do
		playing=$(echo '{"command":["get_property","pause"]}' | socat - "$s" 2>/dev/null | jq -r '.data')
		if [[ "$playing" == "false" ]]; then
			playing_id=$(basename "$s")
			break
		fi
	done

	# 2. If found, tell sway to focus that app_id
	if [[ -n "$playing_id" ]]; then
		echo "Focusing $playing_id..."
		swaymsg "[app_id=\"$playing_id\"] focus"
		printf 'type f\n' | dotoolc
	else
		echo "No active mpv instance found."
	fi
}

# menu: Window Management | 🧲 Steal Active MPV 🎵
win_mpv_steal_active() {
    local socket_dir="/dev/shm/mpvsockets"
    local playing_id=""

    # 1. Find which one is playing (Fast check without jq for speed)
    for s in "$socket_dir"/mpvfloat*; do
        if timeout 0.03 socat - "$s" 2>/dev/null <<< '{"command":["get_property","pause"]}' | grep -q '"data":false'; then
            playing_id=$(basename "$s")
            break
        fi
    done

    # 2. If found, "steal" it to the current workspace and focus
    if [[ -n "$playing_id" ]]; then
        echo "Stealing $playing_id to current workspace..."
        # Move the window to the current workspace and focus it
        swaymsg "[app_id=\"$playing_id\"] move container to workspace current, focus"		
		swaymsg "[app_id=\"$playing_id\"] layout hsplit"

    else
        echo "No active mpv instance found."
    fi
}

# menu: Window Management | 🧲 Steal Active MPV and defloat 🎵
win_mpv_steal_active_defloat() {
    local socket_dir="/dev/shm/mpvsockets"
    local playing_id=""

    # 1. Find which one is playing (Fast check without jq for speed)
    for s in "$socket_dir"/mpvfloat*; do
        if timeout 0.03 socat - "$s" 2>/dev/null <<< '{"command":["get_property","pause"]}' | grep -q '"data":false'; then
            playing_id=$(basename "$s")
            break
        fi
    done

    # 2. If found, "steal" it to the current workspace and focus
    if [[ -n "$playing_id" ]]; then
        echo "Stealing $playing_id to current workspace..."
        # Move the window to the current workspace and focus it
        swaymsg "[app_id=\"$playing_id\"] move container to workspace current, focus"		
		swaymsg "[app_id=\"$playing_id\"] floating disable"
		swaymsg "[app_id=\"$playing_id\"] layout hsplit"

    else
        echo "No active mpv instance found."
    fi
}

# menu: Window Management | 🎼 Realign MPV OpenMusic
win_mpv_realign() {
    local ids=$(ps aux | grep -Eo 'mpvfloat[0-9]+' | sort -u)
    local counter=0
    swaymsg workspace 18
    swaymsg "[app_id=\"^mpvfloat\d+$\"] move to workspace 18"
    while IFS= read -r id; do
        [ -z "$id" ] && continue
        local x=$((2160 + (counter % 10) * 192))
        local y=$((1679 + (counter / 10) * 108))
        swaymsg "[app_id=\"^$id$\"] move to workspace 18, move absolute position ${x}px ${y}px"
        ((counter++))
    done <<<"$ids"
}




# --- FROM FILE: window_management_swayr.sh ---

# --- CATEGORY: SWAYR WINDOW MANAGEMENT ---
# menu: Window Management - swayr | 🥷 Steal window
win_swayr_steal() { swayr steal-window; }

# menu: Window Management - swayr | 🔄 Switch window
win_swayr_switch() { swayr switch-window; }

# menu: Window Management - swayr | 📑 Switch workspace
win_swayr_work() { swayr switch-workspace; }

# menu: Window Management - swayr | 📦 Move focused to workspace
win_swayr_move() { swayr move-focused-to-workspace; }



