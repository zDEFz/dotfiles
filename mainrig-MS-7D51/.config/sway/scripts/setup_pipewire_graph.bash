#!/bin/bash
set -euo pipefail

# Terminate any running qpwgraph instances, ignoring errors if none are found
killall qpwgraph || true

# Define the command for launching qpwgraph
execute="qpwgraph -m -a /home/blu/.config/sway/qpwgraph/mapping.qpwgraph"

# Launch qpwgraph twice, spacing out launches by 2 seconds each
for i in {1..2}; do
    $execute &
    sleep 2
done

sleep 3

# Restart PipeWire and WirePlumber services using brace expansion
systemctl --user restart {pipewire,wireplumber}.service

sleep 5

# Set PipeWire metadata setting for clock force quantum
pw-metadata -n settings 0 clock.force-quantum 256
