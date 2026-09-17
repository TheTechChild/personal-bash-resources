#!/bin/bash

export LDFLAGS="-L/opt/homebrew/opt/postgresql@15/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@15/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@15/lib/pkgconfig"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="/Users/$USER/Library/pnpm"

[ -s "/Users/$USER/.bun/_bun" ] && source "/Users/$USER/.bun/_bun"

# mise replaces nvm, pyenv, and rbenv. It must come after path.sh, so that
# the mise shims stay in front of Homebrew. See shared/mise.sh.
pbr-mise-activate

# Docker CLI completions
fpath=(/Users/$USER/.docker/completions $fpath)
autoload -Uz compinit
compinit

if [ -f "/Users/$USER/.config/fabric/fabric-bootstrap.inc" ]; then
  . "/Users/$USER/.config/fabric/fabric-bootstrap.inc"
fi
