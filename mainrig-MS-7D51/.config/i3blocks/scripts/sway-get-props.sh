swaymsg -t get_tree | jq -r 'recurse(.nodes[]?; .nodes) | select(.focused == true) | "Type: \(.type), App ID: \(.app_id), Name: \(.name), Shell: \(.shell), Con_ID: \(.id)"'
