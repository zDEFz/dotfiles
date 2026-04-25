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
# Force Vulkan renderer for Sway and disable direct scanout for flicker-free performance
export WLR_RENDERER=vulkan
export WLR_SCENE_DISABLE_DIRECT_SCANOUT=1
export GBM_BACKEND=drm
export VAAPI_DRIVER=radeonsi
export LIBVA_DRIVER_NAME=radeonsi

# Get Games running on Wayland with Proton-GE
export PROTON_ENABLE_WAYLAND=1
# Force the AMD driver to keep shader compilers ready
export AMD_DEBUG=precompile,nodcc
# Tell Mesa to use as many threads as you have for shader compilation
export mesa_glthread=true
# Since you have 172GB, don't be shy with the cache
export VK_MAX_PIPELINE_CACHE_SIZE=4G

# Mesa Anti-Lag (Requires Mesa 25.3+)
export VK_LOAD_LAYERS=VK_LAYER_MESA_anti_lag
export WLR_RENDER_NO_EXPLICIT_SYNC=1

# Open Source AMD Vulkan (RADV) Selection
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json
export RADV_EXPERIMENTAL=video_decode 

# --- Toolkit Backends (Wayland Native) ---
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export SDL_VIDEODRIVER=wayland
export MOZ_ENABLE_WAYLAND=1
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export _JAVA_AWT_WM_NONREPARENTING=1

# Silence log-heavy Qt apps (KeePassXC, etc)
export QT_LOGGING_RULES="qt.qpa.wayland=false"

# --- Performance & Build Vars ---
_nprocs=$(nproc)
export MAKEFLAGS="-j$_nprocs"
export NINJAJOBS="$_nprocs"

# --- 196GB RAM: ASD/PSD Managed Caches ---
# These variables point to your /mnt/data paths which ASD then mirrors to RAM via OverlayFS
export MESA_SHADER_CACHE_DIR="$XDG_CACHE_HOME/mesa_shader_cache"
export MESA_SHADER_CACHE_MAX_SIZE="4G" # Boosted to 4G because you have the RAM
export CCACHE_DIR="/mnt/data/cache/ccache"

# --- Go Environment (RAM-Backed) ---
# GOPATH: Persistent binaries (installed tools) stay on SSD/Data for survival
export GOPATH="$XDG_DATA_HOME/go"

# GOCACHE/MODCACHE: Redirected to your ASD-managed folders in RAM
export GOCACHE="/mnt/data/cache/go_build"
export GOMODCACHE="/mnt/data/cache/go_mod"

# Ensure PATH includes Go binaries
export PATH="$PATH:$GOPATH/bin"

# --- Execution ---
_config="$XDG_CONFIG_HOME/sway/config"

# Pre-flight check for sync daemons
if ! pgrep -x "asd" > /dev/null; then
    echo "Warning: ASD is not running. Building on physical disk!"
fi

case "${1:-}" in
    --debug|-d)
        echo "Starting Sway in Debug mode..."
        exec sway -c "$_config" --debug
        ;;
    *)
        exec sway -c "$_config"
        ;;
esac
