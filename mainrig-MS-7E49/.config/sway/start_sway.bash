#!/bin/bash

# --- Build & Performance Optimization ---
# Using persistent SSD storage for CCACHE (as verified by our latency test)
export CCACHE_DIR="/mnt/cache/ccache"
export CCACHE_MAXSIZE=50G
export MAKEFLAGS="-j32"
export NINJAJOBS=32

# Graphics & Driver Tweaks
export RADV_PERFTEST=video_decode
export WLR_RENDERER=vulkan
export WLR_SCENE_DISABLE_DIRECT_SCANOUT=1

# --- Environment Variables for Wayland/Sway ---
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland

# Toolkit Backends
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export NO_AT_BRIDGE=1

# Theming & Qt
export GTK_THEME=Breeze:dark
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# --- Launch Logic ---
CONFIG="$HOME/.config/sway/config"
LOG="$HOME/sway_debug.log"
DEBUG=false  # Set to true for debug mode

# Pre-flight checks
if ! command -v sway >/dev/null; then
  echo "Error: sway not found" >&2
  exit 1
fi

if [ ! -r "$CONFIG" ]; then
  echo "Error: config file not found or unreadable: $CONFIG" >&2
  exit 1
fi

# Ensure CCACHE directory exists with correct permissions
if [ ! -d "$CCACHE_DIR" ]; then
    mkdir -p "$CCACHE_DIR" 2>/dev/null
fi

# Execution
if [ "$DEBUG" = true ]; then
  if [ -e "$LOG" ] && [ ! -w "$LOG" ]; then
    echo "Warning: $LOG not writable, logging to stderr" >&2
    exec sway -c "$CONFIG" --debug
  elif touch "$LOG" 2>/dev/null; then
    exec sway -c "$CONFIG" --debug 2>>"$LOG"
  else
    echo "Warning: can't create $LOG, logging to stderr" >&2
    exec sway -c "$CONFIG" --debug
  fi
else
  # Use exec to replace the shell process with Sway
  exec sway -c "$CONFIG"
fi
