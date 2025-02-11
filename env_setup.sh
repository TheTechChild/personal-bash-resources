#!/bin/bash

# Environment Setup
export NVM_DIR=~/.nvm
export LDFLAGS="-L/opt/homebrew/opt/postgresql@15/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@15/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@15/lib/pkgconfig"
export PYENV_ROOT="$HOME/.penv"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="/Users/$USER/Library/pnpm"

# PATH Configuration
export PATH="$PATH:${GOPATH}/bin"
export PATH="/opt/homebrew/Caskroom/redis-stack-server/7.2.0-v10/bin:$PATH"
export PATH="$PATH:/Users/$USER/.local/bin"
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH="/opt/homebrew/Cellar/python@3.13/3.13.1/bin/:$PATH"

# rbenv setup
eval "$(rbenv init -)"

# nvm setup
source $(brew --prefix nvm)/nvm.sh

# pyenv setup
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# bun setup
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/Users/claytonnoyes/.bun/_bun" ] && source "/Users/claytonnoyes/.bun/_bun"

# pnpm setup
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Terraform setup
alias tf="terraform"

# AWS setup
export AWS_PROFILE="alix-admin"

install_development_languages() {
  # Check and install Ruby via rbenv
  if ! command -v rbenv &> /dev/null; then
    echo "rbenv not found, installing..."
    brew install rbenv
    rbenv init
    eval "$(rbenv init -)"
  fi

  # Install the latest stable Ruby version
  latest_ruby=$(rbenv install -l | grep -v - | tail -1)
  if ! rbenv versions | grep -q "$latest_ruby"; then
    echo "Ruby $latest_ruby not found, installing..."
    rbenv install "$latest_ruby"
    rbenv global "$latest_ruby"
  fi

  # Check and install Python3 via brew
  if ! command -v python3 &> /dev/null; then
    echo "Python3 not found, installing..."
    brew install python
  fi

  # Check and install Zig via brew
  if ! command -v zig &> /dev/null; then
    echo "Zig not found, installing..."
    brew install zig
  fi

  # Check and install Node.js via nvm
  if ! command -v nvm &> /dev/null; then
    echo "nvm not found, installing..."
    brew install nvm
    mkdir ~/.nvm
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bash_profile
    echo '[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"' >> ~/.bash_profile
    source ~/.bash_profile
  fi

  latest_node=$(nvm ls-remote --lts | tail -1 | awk '{print $1}')
  if ! nvm ls | grep -q "$latest_node"; then
    echo "Node.js $latest_node not found, installing..."
    nvm install "$latest_node"
    nvm use "$latest_node"
    nvm alias default "$latest_node"
  fi
}
