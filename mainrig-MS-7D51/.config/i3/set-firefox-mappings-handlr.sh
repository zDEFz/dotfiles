#!/bin/bash

set_xdg_firefox_default() {
    local mime_types=(
        application/x-extension-htm
        application/x-extension-html
        application/x-extension-shtml
        application/x-extension-xht
        application/x-extension-xhtml
        text/html
        text/plain
        text/xml
        application/xml
        application/xhtml+xml
        application/pdf
        application/json
        image/gif
        image/jpeg
        image/png
        image/svg+xml
        video/mp4
        video/webm
        video/ogg
        audio/webm
        audio/ogg
        application/rss+xml
        application/rdf+xml
        application/atom+xml
        application/vnd.mozilla.xul+xml
        x-scheme-handler/about
        x-scheme-handler/chrome
        x-scheme-handler/http
        x-scheme-handler/https
        x-scheme-handler/ftp
        x-scheme-handler/mailto
        x-scheme-handler/magnet
    )

    for type in "${mime_types[@]}"; do
        handlr set "$type" firefox-default.desktop
    done

    handlr set x-scheme-handler/discord-4557121697957+ firefox-default.desktop
    handlr set x-scheme-handler/etcher balena-etcher.desktop
}

set_xdg_firefox_default
