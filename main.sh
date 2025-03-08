#!/bin/bash

# Determine the directory of this main.sh file
PBR_DIR="$HOME/personal-bash-resources"

# Import different bash modules from this repository
source "$PBR_DIR/env_setup.sh"
source "$PBR_DIR/development_resources.sh"
source "$PBR_DIR/gaming_utilities.sh"
source "$PBR_DIR/file_utilities.sh"
source "$PBR_DIR/media_utilities.sh"
source "$PBR_DIR/extensions/index.sh"

# Include any custom shell extensions added by the individual user
source "$PBR_DIR/extensions/index.sh"
