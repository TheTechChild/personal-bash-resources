#!/bin/bash

# Environment Setup
export NVM_DIR=~/.nvm
export LDFLAGS="-L/opt/homebrew/opt/postgresql@15/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@15/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@15/lib/pkgconfig"
export AWS_PROFILE="alix-admin"
export PYENV_ROOT="$HOME/.penv"
export BUN_INSTALL="$HOME/.bun"
export GOPATH=$HOME/Desktop/code/go
export ANDROID_HOME="/Users/claytonnoyes/Library/Android/sdk"
export PNPM_HOME="/Users/claytonnoyes/Library/pnpm"

# PATH Configuration
export PATH="~/Desktop/code/JMJFinancial/hive/bin:/usr/local/sbin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="$PATH:${GOPATH}/bin"
export PATH="/opt/homebrew/Caskroom/redis-stack-server/7.2.0-v10/bin:$PATH"
export PATH="$PATH:/Users/claytonnoyes/.local/bin"
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