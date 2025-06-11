#!/bin/bash

# Define the path where .desktop files will be created
desktop_path="$HOME/.local/share/applications"

echo "Initial cleanup..."

# Safely remove previous cachy- desktop entries
shopt -s nullglob
for file in "$desktop_path"/cachy-*; do
    echo "Removing $file"
    rm "$file"
done
shopt -u nullglob

# Get list of profiles
profiles=$(awk -F= '/^Name=/{print $2}' ~/.cachy/profiles.ini | sort)

# Loop through each profile and create the corresponding .desktop file
echo "Processing profiles..."
while IFS= read -r profile; do
    # Skip empty profile names
    if [[ -z "$profile" ]]; then
        echo "Empty profile, skipping..."
        continue
    fi

    # Skip the default profile if not needed
    if [[ "$profile" == "firefox-default" ]]; then
        echo "Skipping default profile: $profile"
        continue
    fi

    # Define the full path to the .desktop file
    desktop_file="${desktop_path}/${profile}.desktop"

    echo "Creating desktop entry for profile: $profile"

    # Overwrite the .desktop file
    cat <<EOF > "$desktop_file"
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Terminal=false
Exec=/usr/bin/cachy-browser --no-remote -P "$profile" --class "$profile" --name "$profile" %u
Name=$profile
EOF

    if [[ $? -eq 0 ]]; then
        echo "Successfully created $desktop_file"
    else
        echo "Error creating $desktop_file" >&2
    fi
done <<< "$profiles"

# Handle stale global desktop file
global_desktop_file="/usr/share/applications/cachy-browser.desktop"

if [[ -f "$global_desktop_file" ]]; then
    echo "Stale $global_desktop_file found, removing..."
    if sudo rm "$global_desktop_file"; then
        echo "Successfully removed $global_desktop_file."
    else
        echo "Error: Failed to remove $global_desktop_file." >&2
    fi
else
    echo "No stale $global_desktop_file found."
fi
