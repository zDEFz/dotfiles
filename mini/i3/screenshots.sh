#!/bin/bash
if [ "$1" == "CaptureActiveWindow" ]; then
    # Capture active window & open Dolphin
    maim --window "$(xdotool getactivewindow)" \
    ~/Pictures/"$(xdotool getwindowname "$(xdotool getactivewindow)").png"
    notify-send "Captured active window & open Dolphin"
    dolphin ~/Pictures/
fi

if [ "$1" == "CaptureActiveWindowToClipboard" ]; then
    # Capture active window to clipboard
    maim --window "$(xdotool getactivewindow)"
    xclip -selection clipboard -t image/png
    dolphin ~/Pictures/
    notify-send "Captured active window to clipboard"
fi

if [ "$1" == "CaptureEntireScreenToClipboard" ]; then
    # Capture entire screen to clipboard
    maim | xclip -selection clipboard -t image/png
    notify-send "Captured entire screen to clipboard"
    dolphin ~/Pictures/
fi

if [ "$1" == "CaptureSelectedRegionUniqueToClipboard" ]; then
    # Capture selected region with a unique name
    image_path=~/Pictures/"$(uuidgen)".png
    maim --select "$image_path"

    # Copy the image to clipboard using xclip
    xclip -selection clipboard -t image/png -i "$image_path"

    # Notify and open Dolphin
    notify-send "Captured selection region uniquely, image copied to clipboard"
    dolphin ~/Pictures/
fi

if [ "$1" == "CaptureSelectedRegionToClipboard" ]; then
    # Capture selected region to clipboard
    maim --select xclip -selection clipboard -t image/png
    notify-send "Captured selected region to clipboard"
    dolphin ~/Pictures/
fi

if [ "$1" == "CaptureEntireScreen" ]; then
    # Capture entire screen & open Dolphin
    maim ~/Pictures/"$(date +%Y-%m-%d_%H-%M-%S).png"
    notify-send "Captured entire screen & open Dolphin"
    dolphin ~/Pictures/
fi

