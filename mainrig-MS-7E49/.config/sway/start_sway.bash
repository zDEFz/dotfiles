#!/bin/bash

# =============================================================================
# Sway Launch Script - Optimized for Ryzen 9 9950X3D & AMD W7500 GPU
# Hardware: AMD Ryzen 9 9950X3D, AMD Radeon Pro W7500, Arch Linux
# =============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# --- Build & Performance Optimization ---
export CCACHE_DIR="${CCACHE_DIR:-/mnt/cache/ccache}"
export CCACHE_MAXSIZE="50G"
export MAKEFLAGS="-j$(nproc)"
export NINJAJOBS="$(nproc)"

# Ensure ccache directory exists
mkdir -p "$CCACHE_DIR" || {
    echo "Error: Failed to create CCACHE_DIR at $CCACHE_DIR" >&2
    exit 1
}

# --- Graphics & Driver Tweaks for AMD Hardware ---
export RADV_PERFTEST=video_decode
export WLR_RENDERER=vulkan
export WLR_SCENE_DISABLE_DIRECT_SCANOUT=1

# AMD GPU Optimization (W7500)
export AMD_DEBUG=0
export RADV_DEBUG=0
export RADV_SHADER_DEBUG=0
export RADEONCI=0

# --- Environment Variables for Wayland/Sway ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
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

# --- Hardware-Specific Optimizations ---
# Disable compositor optimizations that may conflict with high-end GPU
export WLR_RENDERER=vulkan
export GBM_BACKEND=drm

# Enable hardware acceleration for multimedia
export VAAPI_DRIVER=radeon
export LIBVA_DRIVER_NAME=radeon

# --- Configuration ---
CONFIG="${HOME}/.config/sway/config"
LOG="${HOME}/sway_debug.log"

# Enable debug mode by setting DEBUG=true in environment or as argument
DEBUG=false
if [[ "${DEBUG:-false}" == true ]] || [[ "${1:-}" == "--debug" ]]; then
    DEBUG=true
fi

# --- Pre-flight Checks ---
if ! command -v sway &>/dev/null; then
    echo "Error: sway not found. Please install it." >&2
    exit 1
fi

if [[ ! -r "$CONFIG" ]]; then
    echo "Error: Config file not found or unreadable: $CONFIG" >&2
    exit 1
fi

# --- Logging Setup ---
if [[ "$DEBUG" == true ]]; then
    # Try to write log file; fall back to stderr if needed
    if [[ -e "$LOG" ]] && ! [[ -w "$LOG" ]]; then
        echo "Warning: Log file $LOG not writable. Logging to stderr." >&2
        exec sway -c "$CONFIG" --debug
    elif touch "$LOG" 2>/dev/null; then
        exec sway -c "$CONFIG" --debug 2>>"$LOG"
    else
        echo "Warning: Cannot create log file $LOG. Logging to stderr." >&2
        exec sway -c "$CONFIG" --debug
    fi
else
    # Normal run without debug logging
    exec sway -c "$CONFIG"
fi
