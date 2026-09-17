#!/bin/bash

install_development_languages() {
  local _failed=()

  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ $(uname -m) == "arm64" ]]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    if ! command -v brew &>/dev/null; then
      echo "ERROR: Homebrew failed to install"
      return 1
    fi
  fi

  if ! command -v mise &>/dev/null; then
    echo "mise not found, installing..."
    brew install mise
    if ! command -v mise &>/dev/null; then
      echo "ERROR: mise failed to install"
      return 1
    fi
  fi

  # mise installs Ruby, Python, Node, Zig, Elixir, Bun, Poetry, and Yarn.
  # It replaces rbenv, pyenv, and nvm. See shared/mise.sh.
  _pbr_mise_install_languages

  # Post-install configuration. `mise exec` is necessary because the mise
  # shims reach PATH only after the next shell start.
  mise exec -- poetry config virtualenvs.in-project true 2>/dev/null
  mise exec -- bun completions 2>/dev/null

  echo ""
  if [[ ${#_failed[@]} -gt 0 ]]; then
    echo "DONE with errors. Failed to install: ${_failed[*]}"
    return 1
  else
    echo "All development languages installed successfully."
  fi
}

install_development_tools() {
  local _failed=()

  if ! command -v opencode &>/dev/null; then
    echo "OpenCode CLI not found, installing..."
    curl -fsSL https://opencode.ai/install | bash
    if command -v opencode &>/dev/null; then
      npm install -g oh-my-opencode@latest
    else
      echo "ERROR: opencode failed to install"
      _failed+=("opencode")
    fi
  fi

  if ! [ -d "/Applications/Visual Studio Code.app" ]; then
    echo "VS Code not found, installing..."
    brew install --cask visual-studio-code
    if ! [ -d "/Applications/Visual Studio Code.app" ]; then
      echo "ERROR: VS Code failed to install"
      _failed+=("vscode")
    fi
  fi

  if ! command -v nvim &>/dev/null; then
    echo "Neovim not found, installing..."
    brew install neovim
    if ! command -v nvim &>/dev/null; then
      echo "ERROR: neovim failed to install"
      _failed+=("neovim")
    fi
  fi

  if ! [ -d "/Applications/iTerm.app" ]; then
    echo "iTerm2 not found, installing..."
    brew install --cask iterm2
    if ! [ -d "/Applications/iTerm.app" ]; then
      echo "ERROR: iTerm2 failed to install"
      _failed+=("iterm2")
    fi
  fi

  if ! command -v gtimeout &>/dev/null; then
    echo "coreutils not found, installing..."
    brew install coreutils
    if ! command -v gtimeout &>/dev/null; then
      echo "ERROR: coreutils failed to install"
      _failed+=("coreutils")
    else
      sudo ln -s /usr/local/bin/gtimeout /usr/local/bin/timeout
    fi
  fi

  if ! command -v java &>/dev/null; then
    echo "Java not found, installing..."
    brew install openjdk@17
    if ! command -v java &>/dev/null; then
      echo "ERROR: java failed to install"
      _failed+=("java")
    fi
  fi

  echo ""
  if [[ ${#_failed[@]} -gt 0 ]]; then
    echo "DONE with errors. Failed to install: ${_failed[*]}"
    return 1
  else
    echo "All development tools installed successfully."
  fi
}

install_macos_utilities() {
  local _failed=()

  if ! [ -d "/Applications/MonitorControl.app" ]; then
    echo "MonitorControl not found, installing..."
    brew install --cask monitorcontrol
    if ! [ -d "/Applications/MonitorControl.app" ]; then
      echo "ERROR: MonitorControl failed to install"
      _failed+=("monitorcontrol")
    else
      echo ""
      echo "MonitorControl Configuration Required:"
      echo "1. Open MonitorControl from Applications"
      echo "2. Grant Accessibility permissions when prompted"
      echo "3. Settings > Keyboard:"
      echo "   - Volume control: 'Standard keyboard volume and mute keys'"
      echo "   - Screen to control: Select your monitor or 'Change for all screens'"
      echo "4. Settings > Displays > [Your Monitor]:"
      echo "   - Check 'Disable macOS volume OSD'"
      echo "   - Enable 'Show advanced settings' and click 'Get current' for audio device name"
      echo "5. Quit and relaunch MonitorControl"
    fi
  fi

  echo ""
  if [[ ${#_failed[@]} -gt 0 ]]; then
    echo "DONE with errors. Failed to install: ${_failed[*]}"
    return 1
  else
    echo "All macOS utilities installed successfully."
  fi
}
