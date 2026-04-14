#!/bin/bash

# menu: Browse | 📂 Open Anime Shows Folder
browse_anime_shows_folder() {
	dbus-launch thunar --name Thunar-Animeshows '/mnt/storage/anime/anime-shows'
}

# menu: Browse | 📂 Open Anime Movies Folder
browse_anime_movies_folder() {
	dbus-launch thunar --name Thunar-Animemovies '/mnt/storage/anime/anime-movies'
}

# menu: Browse | 📚 Browse Manga
browse_manga() {
	_open_local_service "manga/"
}


# Only run dispatcher if executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
