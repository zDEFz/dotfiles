#!/bin/bash

# ==================================================
# MERGED LIBRARY FOR ARCHITECTURAL REVIEW
# ==================================================


# --- FROM FILE: applications.sh ---

# --- CATEGORY: APPLICATIONS ---
# menu: Applications | 🔪 Kill Cultris II
app_cultris_kill() {
    pkill -9 -f cultris2.jar && notify-send "Cultris II" "Terminated" || notify-send "Cultris II" "Not running"
}

# menu: Applications | 🎯 Focus OpenTaiko
app_opentaiko_focus() { 
    swaymsg '[class="^(OpenTaiko|opentaiko.exe)$"] focus'
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



# --- FROM FILE: dev_env.sh ---

# --- CATEGORY: DEV ENVIRONMENT ---

# menu: Dev Env | 💻 Cultris Alacritty
dev_cultris_shell() {
    alacritty \
        --config-file "$HOME/.config/alacritty/alacritty_non_opaque.toml" \
        --class alacritty_floating \
        --title "Cultris Dev Env" \
        --working-directory "$HOME/git/c2-patch-deobf" \
        -e $SHELL
}

# menu: Dev Env | 📝 Cultris VSCode
dev_cultris_vscode() {
    local DISK_SRC="$HOME/git/c2-patch-deobf"
    local RAM_ROOT="/dev/shm/cultris-dev"
    local DATA_DIR="/dev/shm/.vscode-c2-dev"
    local LOCK_FILE="/dev/shm/cultris.lock"

    mkdir -p "$RAM_ROOT"
    mkdir -p "$DATA_DIR/User"
    touch "$LOCK_FILE"

    # Initial sync: DISK → RAM (full sync including resources)
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

    cat > "$DATA_DIR/User/settings.json" << EOF
{
    "runOnSave.enabled": true,
    "runOnSave.commands": [{
        "match": ".*\\\\.java$",
        "command": "$REFRESH_CMD",
        "runIn": "terminal"
    }],
    "files.autoSave": "off",
    "files.autoRefresh": true,
    "files.hotExit": "off",
    "files.useExperimentalFileWatcher": true,
    "workbench.editor.checkOutOfSyncFiles": true,
    "files.watcherExclude": {
        "**/.git/*": true,
        "**/resources/libs/**": true
    },
    "files.exclude": {
        "**/*.class": true,
        "**/.git": true,
        "**/binary/*.j": true
    },
    "search.exclude": {
        "**/binary/**": true
    },
    "window.restoreWindows": "none",
    "workbench.editor.revealIfOpen": true,
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

# menu: Dev Env | 📂 Sway Control Panel
dev_sway_config_vscode() {
    code "$HOME/.config/sway/scripts/control_panel/"
}



# --- FROM FILE: display_controls.sh ---

# --- CATEGORY: DISPLAY CONTROLS ---
# Individual Controls
# menu: Display Controls | ✅ Enable L
display_L_on() { swaymsg output "'$L'" enable; }

# menu: Display Controls | ❌ Disable L
display_L_off() { swaymsg output "'$L'" disable; }

# menu: Display Controls | ✅ Enable LL
display_LL_on() { swaymsg output "'$LL'" enable; }

# menu: Display Controls | ❌ Disable LL
display_LL_off() { swaymsg output "'$LL'" disable; }

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

# menu: Display Controls | ✅ Enable RR
display_RR_on() { swaymsg output "'$RR'" enable; }

# menu: Display Controls | ❌ Disable RR
display_RR_off() { swaymsg output "'$RR'" disable; }

# menu: Display Controls | ✅ Enable TAIKO
display_TAIKO_on() { swaymsg output "'$TAIKO'" enable; }

# menu: Display Controls | ❌ Disable TAIKO
display_TAIKO_off() { swaymsg output "'$TAIKO'" disable; }

# Group Controls
# menu: Display Controls | ✅ Enable main support
display_group_main_on() { for d in "$L" "$M" "$R"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | ❌ Disable main support
display_group_main_off() { for d in "$L" "$M" "$R"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable main support and taiko
display_group_main_taiko_on() { for d in "$L" "$M" "$R" "$TAIKO"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | ❌ Disable main support and taiko
display_group_main_taiko_off() { for d in "$L" "$M" "$R" "$TAIKO"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable opt support
display_group_opt_on() { for d in "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | ❌ Disable opt support
display_group_opt_off() { for d in "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable opt support and taiko
display_group_opt_taiko_on() { for d in "$LL" "$MON_KB" "$RR" "$TAIKO"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | ❌ Disable opt support and taiko
display_group_opt_taiko_off() { for d in "$LL" "$MON_KB" "$RR" "$TAIKO"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable support all
display_group_all_on() { for d in "$L" "$M" "$R" "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | ❌ Disable support all
display_group_all_off() { for d in "$L" "$M" "$R" "$LL" "$MON_KB" "$RR"; do swaymsg output "'$d'" disable; done; }

# menu: Display Controls | ✅ Enable all Seat Displays
display_group_seat_on() { for d in "$L" "$LL" "$M" "$MON_KB" "$R" "$RR"; do swaymsg output "'$d'" enable; done; }

# menu: Display Controls | 🔄 Set refresh rate
display_set_hz() {
    RATE=$(wofi --insensitive --dmenu -p "Hz")
    [ -z "$RATE" ] && return
    for i in $(lshz | grep -o "DP-[0-9]"); do swaymsg output "$i" resolution 1920x1080@"$RATE"Hz; done
}




# --- FROM FILE: helpers.sh ---

# --- CATEGORY: HELPERS ---
# Internal helper used for moving containers to specific outputs
_win_move_to_output() { 
    swaymsg move container to output "'${!1}'"
}



# --- FROM FILE: move_window_to_display.sh ---

# --- CATEGORY: MOVE WINDOW TO DISPLAY ---
# menu: Move Window to Display | 🪟 Move to L
win_move_L() { _win_move_to_output L; }

# menu: Move Window to Display | 🪟 Move to LL
win_move_LL() { _win_move_to_output LL; }

# menu: Move Window to Display | 🪟 Move to M
win_move_M() { _win_move_to_output M; }

# menu: Move Window to Display | 🪟 Move to MON_KB
win_move_MON_KB() { _win_move_to_output MON_KB; }

# menu: Move Window to Display | 🪟 Move to R
win_move_R() { _win_move_to_output R; }

# menu: Move Window to Display | 🪟 Move to RR
win_move_RR() { _win_move_to_output RR; }

# menu: Move Window to Display | 🥁 Move to TAIKO
win_move_TAIKO() { _win_move_to_output TAIKO; }




# --- FROM FILE: myanimelist.sh ---

# menu: MyAnimeList | 📺 MAL Synopsis from clipboard
app_mal_synopsis_clip() {
    "$USER_HOME"/.config/sway/scripts/myanimelist_coverart_search.sh "$(wl-paste)"
}




# --- FROM FILE: swayr_window_management.sh ---

# --- CATEGORY: SWAYR WINDOW MANAGEMENT ---
# menu: Swayr Window Management | 🥷 Steal window
win_swayr_steal() { swayr steal-window; }

# menu: Swayr Window Management | 🔄 Switch window
win_swayr_switch() { swayr switch-window; }

# menu: Swayr Window Management | 📑 Switch workspace
win_swayr_work() { swayr switch-workspace; }

# menu: Swayr Window Management | 📦 Move focused to workspace
win_swayr_move() { swayr move-focused-to-workspace; }




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
        --config-file="$USER_HOME/.config/alacritty/alacritty_non_opaque.toml" \
        --class alacritty_floating \
        --title "Floating Terminal" \
        --working-directory "$USER_HOME" \
        -e bash -c "sudo journalctl -f"
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

# menu: Typing Tools | 🏠 Type fritzbox
type_url_fritzbox() { printf 'key leftctrl\ntype %s\n' "http://fritz.box" | dotoolc; }

# menu: Typing Tools | 🏠 Type http+hostname
type_url_hostname() { printf 'key leftctrl\ntype %s\n' "http://$(hostname)/" | dotoolc; }

# menu: Typing Tools | 🎵 Type search audio
type_url_audio_search() { printf 'key leftctrl\ntype %s\n' "http://$(hostname)/audio/search_all" | dotoolc; }

# menu: Typing Tools | 🎮 Type solitaire
type_url_solitaire() { printf 'key leftctrl\ntype %s\n' "http://$(hostname)/shenzhen_solitaire/" | dotoolc; }

# menu: Typing Tools | 🖥️ Type kvm
type_url_kvm() { printf 'key leftctrl\ntype %s\n' "https://kvm" | dotoolc; }

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

# menu: Typing Tools | 📎 x0pipeclip
type_share_clip() {
    source /home/blu/scripts/functions/in_use/transfers/paste_services
    x0pipeclip "$(wl-paste)"
}




# --- FROM FILE: window_management.sh ---

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



