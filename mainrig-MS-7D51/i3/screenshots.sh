#!/bin/bash

notify() {
    notify-send "$1"
}

capture_to_file() {
    local target="$1"
    local filename="$2"
    maim "$target" "$filename" && thunar "$filename" && notify "Captured $3 & opened in Thunar"
}

capture_to_clipboard() {
    local target="$1"
    maim "$target" | xclip -selection clipboard -t image/png && notify "Captured $2 to clipboard"
}

case "$1" in
    "CaptureActiveWindow")
        active_window="$(xdotool getactivewindow)"
        window_name="$(xdotool getwindowname "$active_window")"
        capture_to_file "--window $active_window" "$HOME/Pictures/$window_name.png" "active window"
        ;;

    "CaptureActiveWindowToClipboard")
        capture_to_clipboard "--window $(xdotool getactivewindow)" "active window"
        ;;

    "CaptureEntireScreenToClipboard")
        capture_to_clipboard "" "entire screen"
        ;;

    "CaptureSelectedRegionUniqueToClipboard")
        image_path="$HOME/Pictures/$(uuidgen).png"
        if maim --select "$image_path"; then
            xclip -selection clipboard -t image/png -i "$image_path"
            notify "Captured selected region uniquely, image copied to clipboard"
        fi
        ;;

    "CaptureSelectedRegionToClipboard")
        capture_to_clipboard "--select" "selected region"
        ;;

    "CaptureEntireScreen")
        filename="$HOME/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png"
        capture_to_file "" "$filename" "entire screen"
        ;;
esac
