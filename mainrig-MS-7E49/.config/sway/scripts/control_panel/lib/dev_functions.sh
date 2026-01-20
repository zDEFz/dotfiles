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
    local LOCK_FILE="/dev/shm/cultris.lock"
    
    mkdir -p "$RAM_ROOT"
    mkdir -p "$DATA_DIR/User"
    touch "$LOCK_FILE"
    
    rsync -av "$DISK_SRC/" "$RAM_ROOT/"
    
 # Ensure CP and J_BASE are set as before
    local J_BASE="$RAM_ROOT/resources/jdk-17.0.13+11/bin"
    local CP="$RAM_ROOT/binary:$RAM_ROOT/resources/libs/*"
    local MAIN_CLASS="net.gewaltig.cultris.Cultris"

    # The fixed REFRESH_CMD
    # 1. unsetopt histchars handles the shell behavior
    # 2. fuser kills the previous instance via the lock file
    # 3. javac compiles using the RAM source
    # 4. java launches with the library path pointing to RAM libs
    local REFRESH_CMD="unsetopt histchars 2>/dev/null || true; fuser -k -9 $LOCK_FILE 2>/dev/null || true; $J_BASE/javac -cp '$CP' -sourcepath $RAM_ROOT/binary -d $RAM_ROOT/binary $RAM_ROOT/binary/Mapping.java $RAM_ROOT/binary/*.java \${file} && ($J_BASE/java -Djava.library.path='$RAM_ROOT/resources/libs' -cp '$CP' $MAIN_CLASS & disown) && echo 'REFRESHED'"
    local SAVE_CMD="rsync -av --delete '$RAM_ROOT/' '$DISK_SRC/' && cd '$DISK_SRC/binary' && rm -f ../cultris2.jar && zip -r -9 ../cultris2.jar * -x '*.j' && echo 'DISK UPDATED & JAR REPACKED'"
    
    local REVERT_CMD="cd '$DISK_SRC' && git checkout HEAD -- . ':!resources' && git clean -fd -e resources/ && rsync -av --delete --exclude='resources/' '$DISK_SRC/' '$RAM_ROOT/' && find '$RAM_ROOT/binary' -type f -name '*.java' -exec touch -m {} + && echo 'REVERTED: Resources preserved.'"

    # --- Your Git Logic Commands (Restored) ---
    local G_STATUS="cd '$DISK_SRC' && echo '--- GIT STATUS ---' && git status"
    local G_DIFF="cd '$DISK_SRC' && echo '--- GIT DIFF ---' && git diff"
    local G_PUSH="cd '$DISK_SRC' && echo '--- PUSHING TO REMOTE ---' && git push"
    local G_COMMIT="cd '$DISK_SRC' && git add . && printf 'Enter commit message: ' && read msg && git commit -m \\\"\$msg\\\""
    
    # --- VS Code Settings ---
    cat <<EOF > "$DATA_DIR/User/settings.json"
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

# menu: dev env | Open sway control panel vscode
open_sway_control_panel_vscode() {
	code ~/.config/sway/scripts/control_panel/
}