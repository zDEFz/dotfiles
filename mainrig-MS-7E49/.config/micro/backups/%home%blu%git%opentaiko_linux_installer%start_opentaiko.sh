#!/bin/bash
export XDG_SESSION_TYPE=xcb
export DIR="$HOME/OpenTaiko"

env -C "$DIR" \
    "$HOME"/OpenTaiko_git/publish/OpenTaiko
