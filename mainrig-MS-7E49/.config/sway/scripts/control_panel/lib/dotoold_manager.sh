#!/bin/bash
# dotoold_manager.sh - Manages dotoold daemon

start_dotoold() {
    if ! pgrep -x dotoold >/dev/null; then
        nohup dotoold >/dev/null 2>&1 &
        echo "dotoold started in the background."
    else
        echo "dotoold is already running."
    fi
}
