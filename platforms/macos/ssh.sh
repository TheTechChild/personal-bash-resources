#!/bin/bash

echo "Starting the ssh-agent"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
