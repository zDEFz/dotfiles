#!/bin/bash

set-xdg-firefox-default() {
    # List of common MIME types and protocols for Firefox
    local mime_types=(
        application/x-extension-htm
        application/x-extension-html
        application/x-extension-shtml
        application/x-extension-xht
        application/x-extension-xhtml
        text/html
        video/mp4
        x-scheme-handler/about
        x-scheme-handler/chrome
        x-scheme-handler/http
        x-scheme-handler/https
    )

    # Set Firefox as the default for common types
    for type in "${mime_types[@]}"; do
        handlr set "$type" firefox-default.desktop
    done

    # Specific handler exceptions
    handlr set x-scheme-handler/discord-4557121697957+ firefox-default.desktop
    handlr set x-scheme-handler/etcher balena-etcher.desktop
}

set-xdg-firefox-default
