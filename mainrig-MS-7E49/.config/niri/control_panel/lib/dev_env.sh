#!/bin/bash

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


# Only run dispatcher if executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
