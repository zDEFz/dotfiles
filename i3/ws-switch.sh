#!/bin/bash
# real current workspace

# current workspace - e.g 3=>4 instead of 3
current_workspace=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused == true).name | tonumber | if . % 2 == 1 then . + 1 else . end')

if [ "$1" == "next" ]; then
    nr=$((current_workspace + 2)) # next on right monitor is workspace 3
    nl=$((current_workspace + 1)) # next on left monitor is workspace 2
    i3-msg "workspace $nl, workspace $nr"
fi

if [ "$1" == "prev" ]; then
    nr=$((current_workspace - 2))
    nl=$((current_workspace - 3))
    if [ $nl -gt -1 ]; then
        i3-msg "workspace $nl, workspace $nr"
    fi
fi

# Get the current workspace name directly from i3-msg
current_workspace=$(i3-msg -t get_workspaces | jq -r '..|objects|select(has("focused") and .focused==true)|.name')

solid_black_wallpaper="/home/blu/.config/i3/wallpaper/solid-bg-black.png"

case "$current_workspace" in
    2)
        feh --no-fehbg --bg-fill $solid_black_wallpaper
        ;;
    4)
        feh --no-fehbg --bg-fill "/home/blu/.config/i3/wallpaper/anime-shows/Steins;Gate - 589395.jpg"
        ;;
    6)
        feh --no-fehbg --bg-fill "/home/blu/.config/i3/wallpaper/music-listening/music-melody-abstract-1920x1080.jpg"
        ;;
    8)
    feh --nofehbg --bg-fill "/home/blu/.config/i3/wallpaper/gaming/steam-wallpaper-logo.png"
    ;;

    10)
    feh --nofehbg --bg-center "/home/blu/.config/i3/wallpaper/gaming/slippi.gg.png"
    ;;

    12)
    feh --nofehbg --bg-center "/home/blu/.config/i3/wallpaper/gaming/CodeWeavers-logo.png" 
    #feh --bg-fill path/to/your/image.jpg
    ;;
    *)
        # if it does not match to either, reset wallpaper to solid black
        feh --no-fehbg --bg-fill $solid_black_wallpaper
        ;;
esac