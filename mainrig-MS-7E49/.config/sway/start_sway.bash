#!/bin/bash
# Sway launcher — AMD RDNA3 (RX 9070 XT + iGPU), Wayland-native session
set -euo pipefail

# --- GPU selection (dGPU first, iGPU fallback) ---
export WLR_DRM_DEVICES=/dev/dri/9070xt_card:/dev/dri/igpu_card

# --- XDG base dirs ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# --- wlroots / renderer ---
export WLR_RENDERER=vulkan
export WLR_RENDER_NO_EXPLICIT_SYNC=1
# export WLR_SCENE_DISABLE_DIRECT_SCANOUT=1   # re-enable if you see flicker

# --- Video acceleration ---
export LIBVA_DRIVER_NAME=radeonsi

# --- Proton / gaming ---
export PROTON_ENABLE_WAYLAND=1
export PROTON_FSR4_UPGRADE=1

# --- Mesa ---
export mesa_glthread=true
export MESA_SHADER_CACHE_DIR="$XDG_CACHE_HOME/mesa_shader_cache"
export MESA_SHADER_CACHE_MAX_SIZE=4G
# Mesa Anti-Lag layer (Mesa 25.3+); VK_LOADER_LAYERS_ENABLE is the current loader var
export VK_LOADER_LAYERS_ENABLE=VK_LAYER_MESA_anti_lag
# Pin RADV explicitly if amdvlk/proprietary ICDs are also installed:
# export VK_DRIVER_FILES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json

# --- Toolkit backends (Wayland-native) ---
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export SDL_VIDEODRIVER=wayland,x11
export MOZ_ENABLE_WAYLAND=1
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_LOGGING_RULES="qt.qpa.wayland=false"
export _JAVA_AWT_WM_NONREPARENTING=1

# --- Build performance ---
_nprocs=$(nproc)
export MAKEFLAGS="-j$_nprocs"
export NINJAJOBS="$_nprocs"
export CCACHE_DIR=/mnt/data1/cache/ccache

# --- Go (build caches on ASD/RAM-backed storage, binaries persistent) ---
export GOPATH="$XDG_DATA_HOME/go"
export GOCACHE=/mnt/data1/cache/go_build
export GOMODCACHE=/mnt/data1/cache/go_mod
export PATH="$PATH:$GOPATH/bin"

# --- Launch ---
_config="$XDG_CONFIG_HOME/sway/config"
[[ -r $_config ]] || { echo "sway config not found: $_config" >&2; exit 1; }

case "${1:-}" in
    --debug|-d)
        echo "Starting Sway in debug mode..."
        exec sway -c "$_config" --debug
        ;;
    *)
        exec sway -c "$_config"
        ;;
esac
