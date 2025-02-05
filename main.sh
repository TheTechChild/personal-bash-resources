#!/bin/bash

# main.sh - Main entry point for Personal Bash Resources

# Load all bash functions and scripts
# Add your function and script files here

# Example: Source a script for media manipulation
# source /path/to/media-manipulation.sh

# Example: Source a script for internet content downloading
# source /path/to/internet-content-downloading.sh

# Example: Source a script for file and directory management
# source /path/to/file-directory-management.sh

# Example: Source a script for development environment setup
# source /path/to/dev-env-setup.sh

# Example: Source a script for cursor management
# source /path/to/cursor-management.sh

# Function to list all available functions
list-functions() {
    declare -F | awk '{print $3}'
}

# Add more functions or scripts as needed