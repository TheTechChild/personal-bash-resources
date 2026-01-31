#!/bin/bash

export NVM_DIR="$HOME/.nvm"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/.local/share/pnpm"
export PYENV_ROOT="$HOME/.pyenv"

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

if command -v rbenv &>/dev/null; then
  eval "$(rbenv init -)"
fi

# nvm from pacman installs to /usr/share/nvm
if [[ -s /usr/share/nvm/init-nvm.sh ]]; then
  source /usr/share/nvm/init-nvm.sh
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi

[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

if [ -f "$HOME/.config/fabric/fabric-bootstrap.inc" ]; then
  . "$HOME/.config/fabric/fabric-bootstrap.inc"
fi
