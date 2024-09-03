#!/bin/bash

# Set environment variable to fix fullscreen adaptive sync with Xwayland
# export WLR_DRM_NO_MODIFIERS=1
export XDG_CURRENT_DESKTOP=sway
export QT_QPA_PLATFORMTHEME=qt6ct
export WAYLAND_DEBUG=1
# Launch sway with the desired option
exec sway -c ~/.config/sway/sway-default-config --debug 2>> /home/blu/sway.log
