# AGENTS.md — Personal Bash Resources

> Agentic coding guide for this repository.

## Project Overview

**Personal Bash Resources (PBR)** is a modular, platform-aware shell configuration management system designed for portability across macOS and Arch Linux. It provides automated development environment setup, utility functions, git helpers, media conversion tools, and comprehensive Arch Linux gaming desktop installation scripts.

**Original Purpose**: Package and sync shell environments across machines. Eliminates the pain of reinstalling tools, remembering aliases, and reconfiguring development environments when switching computers or onboarding to new companies.

**Key Features**:
- Platform detection and automatic module loading (macOS, Arch Linux)
- Cross-platform utilities (git, file management, media conversion, AWS)
- Platform-specific installers for development languages and tools
- Full Arch Linux gaming setup (Hyprland/DWM, Steam, Lutris, AMD GPU drivers)
- Encrypted backup/restore system for extensions and sensitive configs
- Extensible architecture for machine-specific customizations

**Stats**: ~1,926 LOC across 26 files, 43+ functions/aliases

**Owner**: TheTechChild  
**License**: GNU GPL v3.0

## Project Structure

```
personal-bash-resources/
├── main.sh                          # Entry point: platform detection, module loading
├── shared/                          # Cross-platform utilities (loaded on all systems)
│   ├── aliases.sh                   # Shell aliases (ll, rsrc, dsp, tf, fabric)
│   ├── aws.sh                       # AWS SSO login helper
│   ├── file_utilities.sh            # File ops (tch, backup-pbr, restore-pbr)
│   ├── git_functions.sh             # Git helpers (git-update-subfolders, install_dependencies)
│   └── media_utilities.sh           # Media conversion (webp→jpg, embed album art)
├── platforms/
│   ├── macos/                       # macOS-specific modules
│   │   ├── init.sh                  # Sources all macOS modules in order
│   │   ├── path.sh                  # Homebrew PATH, PYENV_ROOT, PNPM
│   │   ├── env.sh                   # NVM/BUN/PNPM init, pyenv/rbenv, Docker completions
│   │   ├── ssh.sh                   # ssh-add --apple-use-keychain
│   │   ├── install.sh               # Dev language/tool installers via Homebrew
│   │   └── gaming.sh                # OpenEmu alias
│   └── linux-arch/                  # Arch Linux-specific modules
│       ├── init.sh                  # Sources all Arch modules in order
│       ├── path.sh                  # Linux PATH entries, XDG-compliant paths
│       ├── env.sh                   # pyenv/rbenv init, nvm from pacman path
│       ├── ssh.sh                   # keychain or ssh-agent fallback
│       ├── install.sh               # Dev language/tool installers via pacman/paru
│       └── gaming.sh                # Full Arch gaming setup (700+ LOC)
├── extensions/                      # User-specific configs (gitignored except examples)
│   ├── index.sh                     # Auto-loads all .sh files in extensions/
│   ├── version-managers.sh.example  # Opt-in version managers for Arch
│   └── backup-manifest.sh.example   # Backup manifest template
├── README.md                        # User-facing documentation
└── archbox-build-reference.md       # Arch Linux build notes
```

### Platform Detection

`main.sh` exports `$PBR_PLATFORM` with one of:
- `macos` — Darwin detected
- `linux-arch` — Linux + pacman in PATH
- `linux-unknown` — Linux without pacman
- `unknown` — Everything else

Use `$PBR_PLATFORM` in extensions for platform-specific logic.

### Module Loading Order

1. `main.sh` detects platform, sources `shared/*.sh`
2. `platforms/$PBR_PLATFORM/init.sh` sources platform modules (path → env → ssh → install → gaming)
3. `extensions/index.sh` auto-loads all `extensions/*.sh` (user overrides take priority)

## Script Reference

### Shared Utilities (Cross-Platform)

#### `shared/aliases.sh`
- `ll` — `ls -la`
- `rsrc` — Reload shell config (`source ~/.bashrc`)
- `dsp` — Docker system prune
- `tf` — Terraform alias
- `python2` — Python alias
- `fabric` — fabric-ai alias

#### `shared/git_functions.sh`
- `git-update-subfolders` — Parallel update of all git repos in subdirectories (fetches, pulls current branch, updates trunk)
- `git-update-subfolders-sequential` — Sequential version with verbose output
- `install_dependencies` — Run `yarn install` in folders specified by `$INSTALL_FOLDERS` array
- `install-global-git-ignore` — Symlink and configure global gitignore from `extensions/files/.gitignore_global`

#### `shared/file_utilities.sh`
- `tch <filename>` — Create file and open in VS Code (`code`)
- `backup-pbr-init` — Copy `backup-manifest.sh.example` to `extensions/backup-manifest.sh`
- `backup-pbr [--yolo]` — Backup extensions + external items (SSH keys, tokens) to encrypted `.zip.enc` (or unencrypted with `--yolo`)
- `restore-pbr [file]` — Restore from encrypted/unencrypted backup (auto-detects `.enc` vs `.zip`)
- `restore-pbr-extensions` — Alias for `restore-pbr` (backwards compatibility)
- Internal helpers: `_pbr_resolve_path`, `_pbr_get_manifest_path`, `_pbr_platform_index`

#### `shared/media_utilities.sh`
- `convert_webp_to_jpg <input.webp> <output.jpg>` — Convert WebP to JPG using ffmpeg
- `embed_album_art <image.jpg> <mp3_dir>` — Embed album art into all MP3s in directory

#### `shared/aws.sh`
- `aws-login <profile>` — AWS SSO login and export credentials to environment

### Platform-Specific: macOS

#### `platforms/macos/install.sh`
- `install_development_languages` — Install Ruby (rbenv), Python (pyenv), Node.js (nvm), Zig, Bun, Elixir, Poetry, Yarn via Homebrew
- `install_development_tools` — Install VS Code, Neovim, Java, Docker, kubectl, AWS CLI, Terraform, etc.
- `install_macos_utilities` — Install macOS-specific tools (Rectangle, Alfred, etc.)

#### `platforms/macos/gaming.sh`
- `open-emu` — Alias to open OpenEmu and `~/Games` directory

### Platform-Specific: Arch Linux

#### `platforms/linux-arch/install.sh`
- `install_development_languages` — Install Python, Node.js, Rust, Zig, Bun, Elixir, Go via pacman/paru (system packages, no version managers by default)
- `install_development_tools` — Install Neovim, Docker, kubectl, AWS CLI, Terraform, etc. via pacman/paru

#### `platforms/linux-arch/gaming.sh` (700+ LOC)
**Full Arch Linux gaming desktop setup inspired by Chris Titus Tech.**

**Phased Installation Functions**:
- `arch-setup-base` — Base system (paru AUR helper, snapper/btrfs snapshots, base-devel)
- `arch-setup-shell` — Shell environment (zsh, oh-my-zsh, starship prompt, CTT mybash)
- `arch-setup-desktop-hyprland` — Wayland gaming desktop (Hyprland, Waybar, Kitty, Rofi, Dunst, Hyprpaper, audio/bluetooth)
- `arch-setup-desktop-dwm` — X11 DWM desktop (CTT dwm-titus fork, dmenu, picom, nitrogen)
- `arch-setup-gaming` — Gaming stack (Steam, Lutris, MangoHud, gamemode, AMD GPU drivers, Proton-GE)
- `arch-setup-vm` — QEMU/KVM single-GPU passthrough prep (libvirt, virt-manager, looking-glass)
- `arch-setup-apps` — Common applications (Firefox, Discord, Spotify, OBS, GIMP, etc.)
- `arch-setup-all` — Guided full setup (prompts for desktop choice, runs all phases)

**Internal Helpers** (prefixed with `_arch_`):
- `_arch_print_header`, `_arch_print_step` — Formatted output
- `_arch_check_aur_helper` — Detect paru/yay
- `_arch_install_packages`, `_arch_install_aur_packages` — Package installation wrappers

## Conventions

### Naming
- **Functions**: `function-name` (hyphenated, lowercase) or `function_name` (underscored)
- **Internal helpers**: Prefixed with `_` (e.g., `_pbr_resolve_path`, `_arch_print_header`)
- **Platform-specific**: Prefixed with platform name (e.g., `arch-setup-base`, `install_macos_utilities`)

### Error Handling
- Check for required arguments before execution
- Verify tool availability with `command -v <tool> &>/dev/null`
- Return non-zero exit codes on failure
- Provide usage messages when arguments are missing

### Platform Philosophy
- **macOS**: Homebrew + version managers (nvm, pyenv, rbenv) via platform modules
- **Arch Linux**: System packages via pacman/paru. No version managers by default. Use `.venv` for Python, Docker for isolated environments.
- **Opt-in complexity**: Version managers available via `extensions/version-managers.sh.example` for machines that need them

### Path Management
- All PATH modifications in `platforms/*/path.sh`
- Minimal on Arch — system paths only (version managers opt-in via extensions)
- macOS: Homebrew, PYENV_ROOT, PNPM, etc.

### Extensions
- `extensions/` is gitignored (except `index.sh` and `.example` files)
- Drop any `.sh` file in `extensions/` for auto-loading on shell startup
- Use for machine-specific or sensitive configurations
- Use `$PBR_PLATFORM` inside extensions to handle platform differences

### Backup System
- `backup-pbr` creates AES-256 encrypted archives by default
- Manifest-driven external item backup (SSH keys, tokens, configs)
- Platform-aware restore (uses manifest to determine destination paths)
- SSH permissions auto-fixed on restore (700/600/644)

## Known Limitations / Gotchas

### General
- **No Windows support** — macOS and Linux only
- **Assumes zsh** — If using bash, substitute `.bashrc` for `.zshrc` in setup instructions
- **PBR_DIR must be set** — Required environment variable pointing to installation location

### macOS
- **Homebrew required** — All installers depend on Homebrew
- **Version managers lazy-loaded** — NVM sourced from Homebrew location, may slow shell startup
- **SSH keychain** — Automatically adds SSH keys to macOS keychain on startup (may prompt for passphrase)

### Arch Linux
- **pacman/paru required** — All installers use pacman or paru (AUR helper)
- **Gaming setup assumes AMD GPU** — `arch-setup-gaming` installs AMD drivers by default (modify for NVIDIA)
- **Btrfs recommended** — Snapper snapshots require Btrfs filesystem
- **Single-GPU passthrough** — VM setup is optimized for single-GPU passthrough (advanced use case)
- **No version managers by default** — Use `extensions/version-managers.sh.example` if needed

### Extensions
- **PATH overrides** — Extensions load last, so PATH modifications in extensions will override platform defaults
- **No validation** — Extensions are sourced blindly; syntax errors will break shell startup
- **Backup manifest required** — External item restore requires `backup-manifest.sh` to determine destination paths

### Git Functions
- `git-update-subfolders` — Assumes trunk branch is `main` or `master` (auto-detects from `origin/HEAD`)
- `install_dependencies` — Requires `$INSTALL_FOLDERS` array to be set (will error if not set or not an array)

### Media Utilities
- **ffmpeg required** — Both `convert_webp_to_jpg` and `embed_album_art` require ffmpeg in PATH

### Backup/Restore
- **Password recovery impossible** — Encrypted backups use AES-256; forgotten passwords cannot be recovered
- **Manifest required for restore** — External items cannot be restored without manifest (will preserve in temp directory)
- **Platform-specific paths** — Manifest uses separate paths for macOS/Linux; ensure correct paths for target platform