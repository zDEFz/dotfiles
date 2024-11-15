#!/bin/bash

# Set environment variable to fix fullscreen adaptive sync with Xwayland
# export WLR_DRM_NO_MODIFIERS=1
export XDG_CURRENT_DESKTOP=sway
export QT_QPA_PLATFORMTHEME=qt5ct
export GTK_THEME=Breeze:dark
export XDG_CONFIG_HOME="$HOME/.config"
# Single GPU
export WLR_DRM_DEVICES=/dev/dri/by-name/AMD_6950XT
# Dual GPU with AMD 6950XT as renderer
# export WLR_DRM_DEVICES=/dev/dri/by-name/AMD_6950XT:/dev/dri/by-name/NVIDIA_2000e_Ada

# export WLR_RENDERER=vulkan
# export WAYLAND_DEBUG=1
# Launch sway with the desired option
exec dbus-run-session sway -c /home/blu/.config/sway/config
# --debug 2>> /home/blu/sway.log
