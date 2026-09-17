#!/bin/bash
# Arch Linux shell environment.
#
# mise manages the language versions. It replaces nvm, pyenv, and rbenv.
# Everything else comes from a system package via pacman or paru.

# ── Colors ───────────────────────────────────────────────
eval "$(dircolors -b)"
export LS_COLORS="$LS_COLORS:ow=1;34"

# ── mise ────────────────────────────────────────────────
# Comes after path.sh, so that the mise shims stay in front. See shared/mise.sh.
pbr-mise-activate

# ── Optional tool bootstraps ────────────────────────────
if [ -f "$HOME/.config/fabric/fabric-bootstrap.inc" ]; then
  . "$HOME/.config/fabric/fabric-bootstrap.inc"
fi
