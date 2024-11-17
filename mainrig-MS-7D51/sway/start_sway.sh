#!/bin/bash

# export WLR_DRM_NO_MODIFIERS=1
# export WLR_NO_HARDWARE_CURSORS=1
# export XWAYLAND_NO_GLAMOR=1
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export GTK_THEME=Breeze:dark
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CURRENT_DESKTOP=sway
export _JAVA_AWT_WM_NONREPARENTING=1
# AMD 6950XT as main renderer RX 6400 as secondary
export WLR_DRM_DEVICES=/dev/dri/by-name/AMD_6950XT:/dev/dri/by-name/AMD_RX_6400
# Start sway
exec sway -c /home/blu/.config/sway/config
# exec sway -c /home/blu/.config/sway/config --debug 2>> /home/blu/sway2.log
