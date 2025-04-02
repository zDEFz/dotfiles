#!/bin/bash

# export WLR_DRM_NO_MODIFIERS=1
# export WLR_NO_HARDWARE_CURSORS=1
# export XWAYLAND_NO_GLAMOR=1

#export WINE_WAYLAND_DISPLAY_INDEX=4

# Try to disable at spi2 service start 
export NO_AT_BRIDGE=1

export WLR_SCENE_DISABLE_DIRECT_SCANOUT=1 
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export GTK_THEME=Breeze:dark
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CURRENT_DESKTOP=sway
export _JAVA_AWT_WM_NONREPARENTING=1
# W7500 Pro as primary / W7500_2 as secondary
export WLR_DRM_DEVICES=/dev/dri/by-name/AMD_Pro_W7500:/dev/dri/by-name/AMD_Pro_W7500_2

# Try using vulkan
export WLR_RENDERER=vulkan

# Start sway
exec sway -c /home/blu/.config/sway/config
#exec sway -c /home/blu/.config/sway/config --debug 2>> /home/blu/sway2.log
