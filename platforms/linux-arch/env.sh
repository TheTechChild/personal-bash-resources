#!/bin/bash
# Arch Linux shell environment — system-package-first philosophy.
#
# Version managers (nvm, pyenv, rbenv, etc.) are NOT initialized here.
# Use system packages via pacman. If a specific machine needs version managers,
# add them via an extension — see extensions/version-managers.sh.example.

# ── Colors ───────────────────────────────────────────────
eval "$(dircolors -b)"
export LS_COLORS="$LS_COLORS:ow=1;34"

# ── Optional tool bootstraps ────────────────────────────
if [ -f "$HOME/.config/fabric/fabric-bootstrap.inc" ]; then
  . "$HOME/.config/fabric/fabric-bootstrap.inc"
fi
