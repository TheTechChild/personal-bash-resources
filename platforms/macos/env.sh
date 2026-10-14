#!/bin/bash

export LDFLAGS="-L/opt/homebrew/opt/postgresql@15/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@15/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@15/lib/pkgconfig"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="/Users/$USER/Library/pnpm"

[ -s "/Users/$USER/.bun/_bun" ] && source "/Users/$USER/.bun/_bun"

# mise replaces nvm, pyenv, and rbenv. init.sh activates it after path.sh.
# See shared/mise.sh.

# Docker CLI completions
fpath=(/Users/$USER/.docker/completions $fpath)
autoload -Uz compinit
compinit

if [ -f "/Users/$USER/.config/fabric/fabric-bootstrap.inc" ]; then
  . "/Users/$USER/.config/fabric/fabric-bootstrap.inc"
fi
