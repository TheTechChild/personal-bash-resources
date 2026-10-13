#!/bin/bash

alias ll='ls -la'
alias dsp='docker system prune'
alias tf="terraform"
alias python2='python'
alias fabric='fabric-ai'

rsrc() {
  local rc
  if [ -n "${ZSH_VERSION-}" ]; then
    rc="$HOME/.zshrc"
  elif [ -n "${BASH_VERSION-}" ]; then
    rc="$HOME/.bashrc"
  elif [ -f "$HOME/.zshrc" ]; then
    rc="$HOME/.zshrc"
  else
    rc="$HOME/.bashrc"
  fi

  if [ -f "$rc" ]; then
    echo "Sourcing $rc"
    . "$rc"
  else
    echo "rsrc: $rc not found" >&2
    return 1
  fi
}