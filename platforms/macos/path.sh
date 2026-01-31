#!/bin/bash

export PATH="$PATH:${GOPATH}/bin"
export PATH="$PATH:/Users/$USER/.local/bin"
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH="/opt/homebrew/Caskroom/redis-stack-server/7.2.0-v10/bin:$PATH"
export PATH="/opt/homebrew/Cellar/python@3.13/3.13.1/bin/:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.docker/bin:$PATH"

case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
