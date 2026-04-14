# menu: Applications | wofi mpv playlists
app_mpv_playlists_wofi() {
	bash ~/scripts/snd
}

# menu: Applications | Kill/Close wofi mpv playlists
app_mpv_playlists_wofi_close() {
    local pid_file="/dev/shm/mpv_wofi_playlist.pid"

    if [ -f "$pid_file" ]; then
        local target_pgid=$(cat "$pid_file")
        
        # KILL LOGIC:
        # We send SIGKILL (-9) to the negative PGID (-$target_pgid).
        # This nukes the script, the fd process, and the mpv process simultaneously.
        kill -9 -"$target_pgid" 2>/dev/null
        
        rm -f "$pid_file"
        notify-send "MPV Playlists" "Session $target_pgid Stopped"
    else
        notify-send "MPV Playlists" "No active session found"
    fi
}