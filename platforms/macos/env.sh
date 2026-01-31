#!/bin/bash

export NVM_DIR=~/.nvm
export LDFLAGS="-L/opt/homebrew/opt/postgresql@15/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@15/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@15/lib/pkgconfig"
export PYENV_ROOT="$HOME/.penv"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="/Users/$USER/Library/pnpm"

[ -s "/Users/$USER/.bun/_bun" ] && source "/Users/$USER/.bun/_bun"

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

if command -v rbenv &>/dev/null; then
  eval "$(rbenv init -)"
fi

# nvm lazy-load from Homebrew
if command -v brew &>/dev/null; then
  local_nvm_prefix="$(brew --prefix nvm 2>/dev/null)"
  if [[ -n "$local_nvm_prefix" && -s "$local_nvm_prefix/nvm.sh" ]]; then
    source "$local_nvm_prefix/nvm.sh"
  fi
  unset local_nvm_prefix
fi

# Docker CLI completions
fpath=(/Users/$USER/.docker/completions $fpath)
autoload -Uz compinit
compinit

if [ -f "/Users/$USER/.config/fabric/fabric-bootstrap.inc" ]; then
  . "/Users/$USER/.config/fabric/fabric-bootstrap.inc"
fi
