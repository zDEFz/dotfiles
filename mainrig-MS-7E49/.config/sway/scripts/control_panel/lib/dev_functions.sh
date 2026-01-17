#!/bin/bash

# menu: dev env | Open Cultris Dev Env alacritty shell
open_cultris_dev_alacritty_shell() {
    alacritty \
        --config-file "$HOME/.config/alacritty/alacritty_non_opaque.toml" \
        --class alacritty_floating \
        --title "Cultris Dev Env" \
        --working-directory "$HOME/git/c2-patch-deobf" \
        -e $SHELL
}

# menu: dev env | Open Cultris Dev Env vscode
open_cultris_dev_vscode() {
    local DISK_SRC="$HOME/git/c2-patch-deobf"
    local RAM_ROOT="/dev/shm/cultris-dev"
    local DATA_DIR="/dev/shm/.vscode-c2-dev"
    local J_BASE="$RAM_ROOT/resources/jdk-17.0.13+11/bin"
    local LOCK_FILE="/dev/shm/cultris.lock"
    
    # 1. Clean and Sync
    mkdir -p "$RAM_ROOT"
    touch "$LOCK_FILE"
    rsync -av "$DISK_SRC/" "$RAM_ROOT/"
    
    # 2. Config
    local CP="$RAM_ROOT/binary:$RAM_ROOT/resources/libs/*"
    local MAIN_CLASS="net.gewaltig.cultris.Cultris"
    
    # 3. THE REFRESH COMMAND
    local REFRESH_CMD="unsetopt histchars; fuser -k -9 $LOCK_FILE 2>/dev/null || true; $J_BASE/javac -cp '$CP' -d $RAM_ROOT/binary \${file} && ( ( flock -x 9; cd $RAM_ROOT && taskset -c 0-15 $J_BASE/java -Xshare:auto -XX:TieredStopAtLevel=1 -XX:+UseParallelGC -Djava.library.path=$RAM_ROOT/resources/libs/ -Xms1G -Xmx2G -cp '$CP' $MAIN_CLASS ) 9>>$LOCK_FILE & )"
    
    # 4. SAVE_CMD: Preserves all .java files and EVERYTHING inside the binary folder
    local SAVE_CMD="rsync -av --include='*/' --include='*.java' --include='binary/***' --exclude='*' '$RAM_ROOT/' '$DISK_SRC/'"
    
    # 5. REVERT_CMD: Simple rsync, VSCode will auto-reload with the new setting
    local REVERT_CMD="rsync -av --delete '$DISK_SRC/' '$RAM_ROOT/'"
    
    # 6. VS Code Profile
    mkdir -p "$DATA_DIR/User"
    cat <<EOF > "$DATA_DIR/User/settings.json"
{
    "runOnSave.enabled": true,
    "runOnSave.commands": [{
        "match": ".*\\\\.java$",
        "command": "$REFRESH_CMD",
        "runIn": "terminal"
    }],
    "files.autoSave": "off",
    "files.refactoring.autoSave": false,
    "files.exclude": {
        "**/*.class": true,
        "**/*.class.j": true,
        "**/.git": true
    },
    "files.watcherExclude": {
        "**/*.class": true,
        "**/*.class.j": true,
        "**/binary/**": true
    },
    "search.exclude": {
        "**/*.class": true,
        "**/*.class.j": true,
        "**/binary/": true
    },
    "files.useExperimentalFileWatcher": true,
    "window.restoreWindows": "none",
    "window.autoDetectColorScheme": false,
    "workbench.editor.revealIfOpen": true,
    "actionButtons": {
        "commands": [
            { "name": "🚀 REFRESH", "command": "$REFRESH_CMD", "color": "#ff4500" },
            { "name": "💾 SYNC", "command": "$SAVE_CMD", "color": "#4caf50" },
            { "name": "🔄 REVERT", "command": "$REVERT_CMD", "color": "#ffcc00" }
        ]
    }
}
EOF
    
    code --user-data-dir "$DATA_DIR" "$RAM_ROOT"
}