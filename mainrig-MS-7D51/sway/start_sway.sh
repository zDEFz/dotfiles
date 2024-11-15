#!/bin/bash

# Set environment variable to fix fullscreen adaptive sync with Xwayland
# export WLR_DRM_NO_MODIFIERS=1
export GTK_THEME=Breeze:dark
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CURRENT_DESKTOP=sway
# export XWAYLAND_NO_GLAMOR=1

# Single GPU
# export WLR_DRM_DEVICES=/dev/dri/by-name/AMD_6950XT
# Dual GPU with AMD 6950XT as main renderer
	  export WLR_DRM_DEVICES=/dev/dri/by-name/AMD_6950XT:/dev/dri/by-name/NVIDIA_2000e_Ada
# Dual GPU with NVIDIA_2000e_Ada as main renderer - may require displays to be connected to ADA GPU
	# export WLR_DRM_DEVICES=/dev/dri/by-name/NVIDIA_2000e_Ada:/dev/dri/by-name/AMD_6950XT
	
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER=vulkan

# export WAYLAND_DEBUG=1
# Launch sway with the desired option
# --debug 2>> /home/blu/sway.log
exec sway -c /home/blu/.config/sway/config --unsupported-gpu
