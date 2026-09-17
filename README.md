# Personal Bash Resources

Welcome to the **Personal Bash Resources** repository! This collection of bash functions and resources is designed to automate and simplify a wide variety of tasks, making your programming and daily activities more efficient.

## Overview

This repository includes a diverse set of bash scripts and functions that can help with:

- **Media Manipulation**: Automate tasks like converting, resizing, or organizing media files.
- **File and Directory Management**: Simplify tasks such as renaming, moving, or organizing files and directories.
- **Development Environment Setup**: Set up development environments for different languages across macOS and Arch Linux. One version manager, [mise](https://mise.jdx.dev), controls all of them.
- **Gaming Setup**: Full Arch Linux gaming environment with Hyprland/DWM, Steam, Lutris, and more.

### Original Purpose

The original purpose of this repository was to provide an easy way to package up my shell environment and move it between computers. This allows for seamless uploading of the configuration to a repository or cloud storage, enabling easy retrieval and setup on another computer later. This approach ensures consistency and efficiency across different working environments and computers, since working in tech basically ensures that you are going to be laid off many times as companies shrink and expand.

I got so fed up with having to reinstall everything, remember all of my git aliases, install all of the dependencies for my development environment... It is the worst when trying to onboard to a new company, or even continue side projects that I was previously working on.

This project changes all of that. Now my .zshrc file looks like this:
```
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

PBR_DIR=$HOME/personal-bash-resources
source $PBR_DIR/main.sh
```

## Architecture

PBR uses a platform-aware modular architecture. `main.sh` detects the current platform and loads the appropriate modules automatically.

```
personal-bash-resources/
  main.sh                    # Entry point: detects platform, sources modules
  shared/                    # Cross-platform code (loaded on all systems)
    aliases.sh               # Shell aliases (ll, rsrc, tf, etc.)
    aws.sh                   # AWS CLI helpers (aws-login)
    file_utilities.sh        # File operations (tch, backup-pbr, restore-pbr-extensions)
    git_functions.sh         # Git helpers (git-update-subfolders, install_dependencies)
    media_utilities.sh       # Media conversion (convert_webp_to_jpg, embed_album_art)
    mise.sh                  # mise activation + language list (replaces nvm/pyenv/rbenv)
  platforms/
    macos/                   # macOS-specific modules
      init.sh                # Sources all macOS modules in order
      path.sh                # Homebrew PATH entries, PNPM
      env.sh                 # BUN/PNPM init, mise activation, Docker completions
      ssh.sh                 # ssh-add --apple-use-keychain
      install.sh             # mise for languages, Homebrew for applications
      gaming.sh              # OpenEmu alias
    linux-arch/              # Arch Linux-specific modules
      init.sh                # Sources all Arch modules in order
      path.sh                # Linux PATH entries, XDG-compliant paths
      env.sh                 # mise activation, colors
      ssh.sh                 # keychain or ssh-agent fallback
      install.sh             # mise for languages, pacman/paru for applications
      gaming.sh              # Full Arch gaming setup (Hyprland, DWM, Steam, Lutris, etc.)
  extensions/                # User-specific configs (gitignored)
    index.sh                 # Auto-loads all .sh files in extensions/
    *.sh                     # Your custom configs go here
```

### Platform Detection

`main.sh` exports `PBR_PLATFORM` with one of these values:

| Value | Detected When |
|-------|---------------|
| `macos` | `uname -s` returns `Darwin` |
| `linux-arch` | Linux + `pacman` found in PATH |
| `linux-unknown` | Linux without pacman |
| `unknown` | Everything else |

Use `$PBR_PLATFORM` in your extensions for platform-specific logic:
```bash
case "$PBR_PLATFORM" in
    macos)      echo "Running on macOS" ;;
    linux-arch) echo "Running on Arch" ;;
esac
```

### Getting Started

**Supported platforms**: macOS, Arch Linux. No Windows support planned.

If you use `.bashrc` instead of `.zshrc`, substitute accordingly.

1. Set the install location:
   ```
   INSTALL_LOCATION=$HOME
   ```

2. Clone the repo:
   ```
   git clone https://github.com/TheTechChild/personal-bash-resources.git $INSTALL_LOCATION/personal-bash-resources
   ```

3. Add to your shell config:
   ```
   echo "PBR_DIR=$INSTALL_LOCATION/personal-bash-resources" >> ~/.zshrc
   echo 'source $PBR_DIR/main.sh' >> ~/.zshrc
   ```

4. Reload:
   ```
   source ~/.zshrc
   ```

### Extensions

The `extensions/` directory is gitignored (except `index.sh`) and is where you put machine-specific or sensitive configurations. Any `.sh` file dropped in there is automatically sourced on shell startup.

Use `$PBR_PLATFORM` inside extensions to handle platform differences without duplicating files.

## Key Functions

### Version Management (mise)

PBR uses [mise](https://mise.jdx.dev) for all language versions. One tool
replaces nvm, pyenv, and rbenv.

mise reads these files, and it changes the version when you change directory:
`mise.toml`, `.tool-versions`, `.nvmrc`, `.node-version`, `.ruby-version`,
`.python-version`.

| Task | Command |
|------|---------|
| Set a version for a project | `mise use node@20.16.0` |
| Set a default for the machine | `mise use -g node@22` |
| Install the versions a repo asks for | `mise install` |
| Show the versions in use here | `mise current` |
| Run a tool without a shell restart | `mise exec -- terraform version` |

mise activates in `platforms/$PBR_PLATFORM/env.sh`, after `path.sh`. The
`pbr-mise-activate` function in `shared/mise.sh` does the work, and it does
nothing if mise is absent.

**Coming from nvm, pyenv, or rbenv**: remove their `init` lines from your
shell config first. Two managers on one PATH give problems that are difficult
to find. `extensions/version-managers.sh.example` keeps the old code, if one
machine still needs it.

### Development Environment
- `install_development_languages` - Install Ruby, Python, Node.js, Zig, Bun, Elixir, Poetry, and Yarn with [mise](https://mise.jdx.dev)
- `install_development_tools` - Install editors (VS Code, Neovim), Java, Docker, and more

### Git
- `gp` / `gpl` / `gco` / `gcb` / `gcm` / `gdel` - Common git aliases
- `git-update-subfolders` - Update all git repos in subdirectories
- `install_dependencies` - Run yarn install in specified subdirectories
- `install-global-git-ignore` - Configure global gitignore

### File Utilities
- `tch` - Create file and open in editor
- `backup-pbr` - Backup extensions directory
- `restore-pbr-extensions` - Restore extensions from backup

### Media
- `convert_webp_to_jpg` - Convert WebP images to JPG
- `embed_album_art` - Add album art to MP3 files

### Arch Linux Gaming (linux-arch only)
- `arch-setup-base` - Base packages, AUR helper, networking
- `arch-setup-shell` - Zsh, Oh My Zsh, Starship prompt
- `arch-setup-desktop-hyprland` - Hyprland desktop environment
- `arch-setup-desktop-dwm` - DWM desktop environment
- `arch-setup-gaming` - Steam, Lutris, MangoHud, AMD GPU drivers
- `arch-setup-vm` - Virtual machine support (QEMU/KVM)
- `arch-setup-all` - Run all setup phases

## Usage

List available functions: `list-functions`

Get help for a function: `function-name --help`

## Contributing

Contributions are welcome! Fork the repository and submit a pull request.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
