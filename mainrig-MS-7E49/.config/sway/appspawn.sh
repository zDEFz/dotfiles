[ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] && exit

if swaymsg "[$1=\"$2\"] scratchpad show"; then
   swaymsg "[$1=\"$2\"] move position center"
else
  swaymsg "exec --no-startup-id $(echo "$@" | cut -d ' ' -f3-)"
fi
