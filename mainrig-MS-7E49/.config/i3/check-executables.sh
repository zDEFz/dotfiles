#!/bin/bash

config_file="/home/blu/.config/i3/conf.d/4-app-autostart.conf"

# Read executables from the specified config file
executables=($(grep -o 'exec [^ ]*' "$config_file" | cut -d ' ' -f 2))

for exe in "${executables[@]}"; do
    if command -v "$exe" &>/dev/null; then
        echo -e "\e[32m$exe exists on your system.\e[0m"  # Green color for existing executables
    else
        echo -e "\e[31m$exe does not exist on your system.\e[0m"  # Red color for non-existing executables
    fi
done
