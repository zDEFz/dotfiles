#!/bin/bash

# --- Build & Performance Optimization ---
export CCACHE_DIR="/mnt/cache/ccache"
export CCACHE_MAXSIZE=50G
export MAKEFLAGS="-j32"
export NINJAJOBS=32

# --- AMD AI & GPU Optimization (Added for W7500/9950X3D) ---
# Tricking ROCm to see the W7500 (gfx1102) as a supported W7700 (gfx1101)
export HSA_OVERRIDE_GFX_VERSION=11.0.1
# Optimizing thread allocation for dual-CCD 9950X3D (Llama.cpp optimization)
export OMP_NUM_THREADS=16

# --- Ollama Concurrency (For your 192GB RAM) ---
# Since you have massive RAM, allow multiple models to stay loaded
export OLLAMA_MAX_LOADED_MODELS=5
export OLLAMA_NUM_PARALLEL=4

# --- Graphics & Driver Tweaks ---
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

# --- CPU Performance Governor ---
# Force CPU out of powersave mode for faster inference
if command -v cpupower >/dev/null; then
    sudo cpupower frequency-set -g performance
fi

# --- Launch Logic ---
CONFIG="$HOME/.config/sway/config"
LOG="$HOME/sway_debug.log"
DEBUG=false

# Pre-flight checks
if ! command -v sway >/dev/null; then
  echo "Error: sway not found" >&2
  exit 1
fi

# Execution
if [ "$DEBUG" = true ]; then
    exec sway -c "$CONFIG" --debug 2>>"$LOG"
else
    exec sway -c "$CONFIG"
fi
