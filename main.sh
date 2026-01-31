#!/bin/bash

PBR_DIR="$HOME/personal-bash-resources"

# Detect platform
case "$(uname -s)" in
    Darwin)  PBR_PLATFORM="macos" ;;
    Linux)
        if command -v pacman &>/dev/null; then
            PBR_PLATFORM="linux-arch"
        else
            PBR_PLATFORM="linux-unknown"
        fi
        ;;
    *)       PBR_PLATFORM="unknown" ;;
esac
export PBR_PLATFORM

# Source shared modules
for _pbr_f in "$PBR_DIR/shared"/*.sh; do
    [[ -f "$_pbr_f" ]] && source "$_pbr_f"
done
unset _pbr_f

# Source platform-specific modules
if [[ -f "$PBR_DIR/platforms/$PBR_PLATFORM/init.sh" ]]; then
    source "$PBR_DIR/platforms/$PBR_PLATFORM/init.sh"
fi

# Source extensions (last — user overrides take priority)
source "$PBR_DIR/extensions/index.sh"
