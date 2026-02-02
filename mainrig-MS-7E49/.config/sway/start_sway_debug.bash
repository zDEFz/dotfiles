#!/bin/bash

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# --- Build & Performance Optimization ---
export CCACHE_DIR="${CCACHE_DIR:-/tmp/ccache}"
export CCACHE_MAXSIZE="50G"

# Fix SC2155: Declare then export
MAKEFLAGS="-j$(nproc)"
export MAKEFLAGS

NINJAJOBS="$(nproc)"
export NINJAJOBS

mkdir -p "$CCACHE_DIR"

# --- Graphics & Driver Tweaks (AMD W7500 / RDNA) ---
export WLR_RENDERER=vulkan
export WLR_SCENE_DISABLE_DIRECT_SCANOUT=1
export GBM_BACKEND=drm

export VAAPI_DRIVER=radeonsi
export LIBVA_DRIVER_NAME=radeonsi
export VDPAU_DRIVER=radeonsi

export RADV_PERFTEST=video_decode
export AMD_DEBUG=0
export RADV_DEBUG=0

# --- Environment Variables for Wayland/Sway ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland

# Ensure Runtime Dir exists (Crucial for Polkit/D-Bus)
if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
    # Fix SC2155: Assign to local variable first
    XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export XDG_RUNTIME_DIR
fi

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

# --- Configuration ---
CONFIG="$HOME/.config/sway/sway-default-config-mod"
LOG="${HOME}/sway_debug_2.log"

# --- Pre-flight Checks ---
if ! command -v sway &>/dev/null; then
    echo "Error: sway not found." >&2
    exit 1
fi

if [[ ! -r "$CONFIG" ]]; then
    echo "Error: Config file not found or unreadable: $CONFIG" >&2
    exit 1
fi

# --- Logic & Execution ---
case "${1:-}" in
    --debug|-d)
        [[ ! -f "$LOG" ]] && touch "$LOG"
        
        echo "Starting Sway in Debug Mode..."
        exec sway -c "$CONFIG" --debug 2>&1 | tee "$LOG"
        ;;
    *)
        exec sway -c "$CONFIG"
        ;;
esac
