#!/bin/bash

# Environment Variables for Wayland and Sway
export ELECTRON_OZONE_PLATFORM_HINT=wayland   # Use Wayland for Electron apps
export GTK_THEME=Breeze:dark                  # Set GTK theme
export _JAVA_AWT_WM_NONREPARENTING=1          # Fix Java AWT issues on Wayland
export MOZ_ENABLE_WAYLAND=1
export NO_AT_BRIDGE=1                          # Disable AT-SPI2 service
export QT_QPA_PLATFORMTHEME=qt5ct             # Set QT platform theme
export QT_QPA_PLATFORM=wayland
export RADV_PERFTEST=video_decode             # Enable better video decoding for MPV
# wexport WLR_DRM_DEVICES=/dev/dri/by-name/AMD_6950XT:/dev/dri/by-name/AMD_Pro_W7500
export WLR_RENDERER=vulkan                    # Use Vulkan renderer for better performance
export WLR_SCENE_DISABLE_DIRECT_SCANOUT=1     # Disable direct scanout for WLR scene
export XDG_CONFIG_HOME="$HOME/.config"        # Set XDG config home
export XDG_CURRENT_DESKTOP=sway               # Set current desktop environment

# Uncomment if needed for specific hardware or software issues
# export WLR_DRM_NO_MODIFIERS=1               # Disable DRM modifiers
# export WLR_NO_HARDWARE_CURSORS=1            # Disable hardware cursors
# export XWAYLAND_NO_GLAMOR=1                 # Disable glamor for XWayland
# export WINE_WAYLAND_DISPLAY_INDEX=4         # Set Wayland display index for Wine

#!/bin/bash
CONFIG="$HOME/.config/sway/config"
LOG="$HOME/sway_debug.log"
DEBUG=true  # set to true for debug mode

if ! command -v sway >/dev/null; then
  echo "Error: sway not found" >&2
  exit 1
fi

if [ ! -r "$CONFIG" ]; then
  echo "Error: config file not found or unreadable: $CONFIG" >&2
  exit 1
fi

if "$DEBUG"; then
  if [ -e "$LOG" ] && [ ! -w "$LOG" ]; then
    echo "Warning: $LOG not writable, logging to stderr" >&2
    sway -c "$CONFIG" --debug
  elif touch "$LOG" 2>/dev/null; then
    sway -c "$CONFIG" --debug 2>>"$LOG"
  else
    echo "Warning: can't create $LOG, logging to stderr" >&2
    sway -c "$CONFIG" --debug
  fi
else
  sway -c "$CONFIG"
fi
