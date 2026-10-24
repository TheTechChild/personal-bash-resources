#!/bin/bash

# Ctrl+Left and Ctrl+Right move one word back or forward.
# iTerm2 and most Linux terminals send ESC[1;5D and ESC[1;5C for these keys.
# On macOS, turn off the Mission Control "Move left/right a space" shortcuts,
# or macOS takes these keys before the terminal gets them.

if [ -n "${ZSH_VERSION-}" ]; then
  if [[ -o interactive ]]; then
    bindkey '^[[1;5D' backward-word
    bindkey '^[[1;5C' forward-word
  fi
elif [ -n "${BASH_VERSION-}" ]; then
  # bind fails when readline is off, for example in a script.
  if [[ $- == *i* ]]; then
    bind '"\e[1;5D": backward-word'
    bind '"\e[1;5C": forward-word'
  fi
fi
