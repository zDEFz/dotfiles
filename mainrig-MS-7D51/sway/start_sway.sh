#!/bin/bash

# Set environment variable to fix fullscreen adaptive sync with Xwayland
# export WLR_DRM_NO_MODIFIERS=1
export GTK_THEME=Breeze:dark
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CURRENT_DESKTOP=sway
# export XWAYLAND_NO_GLAMOR=1

# AMD 6950XT as main renderer RX 6400 as secondary
export WLR_DRM_DEVICES=/dev/dri/by-name/AMD_6950XT:/dev/dri/by-name/AMD_RX_6400
# export WLR_NO_HARDWARE_CURSORS=1

exec sway -c /home/blu/.config/sway/config
# --debug 2>> /home/blu/sway2.log
