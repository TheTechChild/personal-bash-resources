#!/bin/bash

if command -v keychain &>/dev/null; then
  eval "$(keychain --eval --quiet id_ed25519)"
elif [[ -z "$SSH_AUTH_SOCK" ]]; then
  eval "$(ssh-agent -s)" &>/dev/null
  ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
