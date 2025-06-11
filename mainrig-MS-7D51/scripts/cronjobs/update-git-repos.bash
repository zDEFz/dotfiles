#!/bin/bash
NON_ROOT_USER="blu"
USER_HOME="/home/$NON_ROOT_USER"
# List of repositories with absolute paths
repos=(
    "${USER_HOME}/git/dotfiles"
    "${USER_HOME}/git/kdbx"
    "${USER_HOME}/git/codeberg/kdbx"
    "${USER_HOME}/git/mainrig-ms-7d51"
)
for repo in "${repos[@]}"; do
	echo $repo
done

# Loop through repositories, add, commit, and push
for repo in "${repos[@]}"; do
    cd "$repo" || { notify-send "Error" "Failed to cd into $repo"; continue; }
    git add . || { notify-send "Error" "Failed to add changes in $repo"; continue; }
    git commit -m "Update on $(date)" || { notify-send "Error" "Failed to commit in $repo"; continue; }
    git push origin main || { notify-send "Error" "Failed to push changes in $repo"; continue; }
    git push secondary|| { notify-send "Error" "Failed to push changes in $repo"; continue; }
done
