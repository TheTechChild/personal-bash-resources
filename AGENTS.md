# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Bash Resources (PBR) is a modular shell configuration management system designed for portability across macOS and Linux systems. It provides automated development environment setup, utility functions, and an extensible architecture for custom configurations.

## Architecture

### Core Structure
- **main.sh**: Entry point that sources all modules in correct order
- **Core modules**: Each handles specific functionality (development, file utilities, media, gaming, etc.)
- **extensions/**: Directory for user-specific customizations that auto-load
- **PBR_DIR**: Environment variable pointing to installation location

### Module Loading Order
1. `main.sh` sources core modules
2. `extensions/index.sh` auto-loads all .sh files in extensions directory
3. All functions become available in shell

## Common Commands

### Testing Changes
```bash
# Reload shell configuration after changes
source ~/.bashrc  # or source ~/.bashrc

# List available functions
list-functions

# Test a specific function
function-name --help
```

### Extension Management
```bash
# Backup extensions directory
backup-pbr

# Restore extensions from backup
restore-pbr-extensions /path/to/backup.zip
```

## Development Guidelines

### Adding New Functions
1. Choose appropriate module file (or create new one)
2. Follow naming convention: `function-name` (hyphenated, lowercase)
3. Add help text when appropriate
4. Check for required tools/dependencies before executing

### Creating Extensions
1. Add .sh file to `extensions/` directory
2. File will auto-load on next shell startup
3. Use for company-specific or sensitive configurations
4. Extensions are gitignored by default

### Module Patterns
- **Error Handling**: Check for required arguments/tools
- **Platform Support**: macOS and Linux only
- **Path Management**: All PATH modifications in `path.sh` (minimal on Arch — system paths only)
- **Tool Detection**: Use `command -v` to check if tools exist
- **Arch Linux**: Prefer system packages via pacman over version managers. Use `.venv` for Python, Docker for isolated environments.

## Key Features

### Development Environment
- **Arch Linux philosophy**: System packages via pacman. No version managers by default.
- **macOS philosophy**: Homebrew + version managers (nvm, pyenv, rbenv) via platform modules.
- **Opt-in complexity**: Version managers available via `extensions/version-managers.sh.example` for machines that need them.
- **Languages available via pacman**: Python, Node.js, Rust, Zig, Bun, Elixir, Go
- **Cloud/Infra**: Docker, kubectl, AWS CLI (install via pacman when needed)

### Git Aliases
- `gp`: git push
- `gpl`: git pull  
- `gco`: git checkout
- `gcb`: git checkout -b
- `gcm`: git commit -m
- `gdel`: git branch -d
- `git-update-subfolders`: Update all git repos in subdirectories

### Utility Functions
- `tch`: Create file and open in Cursor
- `install_dependencies`: Run yarn install in specified subdirectories
- `webp-to-jpg`: Convert WebP images to JPG
- `add-album-art-to-mp3`: Embed artwork in MP3 files

## Installation Locations
- Default: `$HOME/personal-bash-resources`
- Custom: Set via `INSTALL_LOCATION` during setup
- Shell config: Add PBR_DIR and source main.sh

## Important Notes
- SSH keys auto-added to keychain on startup
- Global gitignore configured automatically
- NVM lazy-loaded from Homebrew location (macOS only — not used on Arch)
- Extensions not tracked in git (add sensitive data here)
- On Arch: version managers are opt-in via extensions, not loaded by default
- Example extensions: `version-managers.sh.example`, `backup-manifest.sh.example`