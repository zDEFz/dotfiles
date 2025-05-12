#!/bin/bash

# Set environment variable to fix fullscreen adaptive sync with Xwayland
# export WLR_DRM_NO_MODIFIERS=1
export XDG_CURRENT_DESKTOP=sway
export QT_QPA_PLATFORMTHEME=qt5ct
export WAYLAND_DEBUG=1

export WLR_DRM_DEVICES=/dev/dri/by-name/AMD_6950XT:/dev/dri/by-path/platform-evdi.0-card
# Launch sway with the desired option
exec sway -c $HOME/.config/sway/sway-default-config-mod --unsupported-gpu --debug 2>> $HOME/sway-debug2.log
