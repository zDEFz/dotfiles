#!/bin/bash

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# --- Build & Performance Optimization ---
export CCACHE_DIR="${CCACHE_DIR:-/tmp/ccache}"
export CCACHE_MAXSIZE="50G"
export MAKEFLAGS="-j$(nproc)"
export NINJAJOBS="$(nproc)"

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
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland

# Ensure Runtime Dir exists (Crucial for Polkit/D-Bus)
if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
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
CONFIG="${HOME}/.config/sway/config"
LOG="${HOME}/sway_debug.log"

# Debug Logic
DEBUG=false
if [[ "${1:-}" == "--debug" ]]; then
    DEBUG=true
fi

# --- Pre-flight Checks ---
if ! command -v sway &>/dev/null; then
    echo "Error: sway not found." >&2
    exit 1
fi

if [[ ! -r "$CONFIG" ]]; then
    echo "Error: Config file not found or unreadable: $CONFIG" >&2
    exit 1
fi

# --- Start Sway inside DBus session (CRITICAL FIX) ---
if [[ "$DEBUG" == true ]]; then
    echo "Starting Sway in Debug Mode (with DBus)..."
    exec dbus-run-session sway -c "$CONFIG" --debug 2>&1 | tee "$LOG"
else
    exec dbus-run-session sway -c "$CONFIG"
fi
