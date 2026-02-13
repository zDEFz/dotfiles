#!/bin/bash

# --- Safety ---
set -euo pipefail

# --- Essential Paths ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Fix SC2155: Declare then export
if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
    _uid=$(id -u)
    XDG_RUNTIME_DIR="/run/user/$_uid"
    export XDG_RUNTIME_DIR
fi

# --- AMD W7500 / RDNA 3 Lean Stack ---
export WLR_RENDERER=vulkan
export WLR_SCENE_DISABLE_DIRECT_SCANOUT=1
export GBM_BACKEND=drm
export VAAPI_DRIVER=radeonsi
export LIBVA_DRIVER_NAME=radeonsi

# Ensure we use RADV (Open Source AMD Vulkan)
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json
export RADV_PERFTEST=video_decode

# Modern Mesa Shader Cache (Replaces deprecated GLSL_CACHE)
export MESA_SHADER_CACHE_DIR="$XDG_CACHE_HOME/mesa_shader_cache"
export MESA_SHADER_CACHE_MAX_SIZE="2G"

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

# --- Performance & Build Vars ---
_nprocs=$(nproc)
export MAKEFLAGS="-j$_nprocs"
export NINJAJOBS="$_nprocs"
export CCACHE_DIR="${CCACHE_DIR:-$XDG_CACHE_HOME/ccache}"

# --- Logic & Execution ---
_config="$XDG_CONFIG_HOME/sway/config"

case "${1:-}" in
    --debug|-d)
        echo "Starting Sway in Debug mode..."
        exec sway -c "$_config" --debug
        ;;
    *)
        exec sway -c "$_config"
        ;;
esac
