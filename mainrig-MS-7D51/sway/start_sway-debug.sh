#!/bin/bash

# Set environment variable to fix fullscreen adaptive sync with Xwayland
# export WLR_DRM_NO_MODIFIERS=1
export XDG_CURRENT_DESKTOP=sway
export QT_QPA_PLATFORMTHEME=qt5ct
export WAYLAND_DEBUG=1
# Launch sway with the desired option
exec sway -c $HOME/.config/sway/config --debug 2>> $HOME/sway.log
