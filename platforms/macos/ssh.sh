#!/bin/bash

if [[ -f ~/.ssh/id_ed25519 ]] && command -v ssh-add &>/dev/null; then
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null
fi
