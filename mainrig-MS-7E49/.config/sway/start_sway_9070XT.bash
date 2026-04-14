#!/bin/bash

# --- Safety & Environment ---
set -euo pipefail

# --- Essential XDG Paths ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Fix SC2155: Ensure XDG_RUNTIME_DIR is valid
if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
    _uid=$(id -u)
    XDG_RUNTIME_DIR="/run/user/$_uid"
    export XDG_RUNTIME_DIR
fi

# --- AMD Radeon W7500 (RDNA 3) Lean Stack ---
export WLR_DRM_DEVICES=/dev/dri/9070xt_main
export WLR_RENDERER=vulkan
export WLR_SCENE_DISABLE_DIRECT_SCANOUT=1

# --- GBM & DRI Settings (Requested Fix) ---
export GBM_BACKEND=dri
export LIBVA_DRIVER_NAME=radeonsi
export VAAPI_DRIVER=radeonsi

# --- Firefox & Rendering Stability ---
export MOZ_ENABLE_WAYLAND=1
export MOZ_DISABLE_RDD_SANDBOX=1
export EGL_PLATFORM=wayland

# --- Mesa Anti-Lag (Requires Mesa 25.3+) ---
# export VK_LOAD_LAYERS=VK_LAYER_MESA_anti_lag
export WLR_RENDER_NO_EXPLICIT_SYNC=1

# --- Toolkit Backends (Wayland Native) ---
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export SDL_VIDEODRIVER=wayland
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export _JAVA_AWT_WM_NONREPARENTING=1

# Silence log-heavy Qt apps
export QT_LOGGING_RULES="qt.qpa.wayland=false"

# --- Performance & Build Vars ---
_nprocs=$(nproc)
export MAKEFLAGS="-j$_nprocs"
export NINJAJOBS="$_nprocs"

# --- 196GB RAM: ASD/PSD Managed Caches ---
export MESA_SHADER_CACHE_DIR="$XDG_CACHE_HOME/mesa_shader_cache"
export MESA_SHADER_CACHE_MAX_SIZE="4G" 
export CCACHE_DIR="/mnt/data/cache/ccache"

# --- Go Environment (RAM-Backed) ---
export GOPATH="$XDG_DATA_HOME/go"
export GOCACHE="/mnt/data/cache/go_build"
export GOMODCACHE="/mnt/data/cache/go_mod"
export PATH="$PATH:$GOPATH/bin"

# --- Execution ---
_config="$XDG_CONFIG_HOME/sway/config_2"

case "${1:-}" in
    --debug|-d)
        echo "Starting Sway in Debug mode..."
        exec sway -c "$_config" --debug
        ;;
    *)
        exec sway -c "$_config"
        ;;
esac
