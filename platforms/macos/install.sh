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

  if ! command -v rbenv &>/dev/null; then
    echo "rbenv not found, installing..."
    brew install rbenv
    if ! command -v rbenv &>/dev/null; then
      echo "ERROR: rbenv failed to install"
      _failed+=("rbenv")
    else
      rbenv init
      eval "$(rbenv init -)"
    fi
  fi

  if command -v rbenv &>/dev/null; then
    latest_ruby=$(rbenv install -l | grep -v - | tail -1)
    if ! rbenv versions | grep -q "$latest_ruby"; then
      echo "Ruby $latest_ruby not found, installing..."
      if ! rbenv install "$latest_ruby"; then
        echo "ERROR: Ruby $latest_ruby failed to install"
        _failed+=("ruby-$latest_ruby")
      else
        rbenv global "$latest_ruby"
      fi
    fi
  fi

  if ! command -v pyenv &>/dev/null; then
    echo "pyenv not found, installing..."
    brew install pyenv
    if ! command -v pyenv &>/dev/null; then
      echo "ERROR: pyenv failed to install"
      _failed+=("pyenv")
    else
      eval "$(pyenv init -)"
    fi
  fi

  if command -v pyenv &>/dev/null && ! command -v python3 &>/dev/null; then
    echo "Python3 not found, installing..."
    latest_python=$(pyenv install --list | grep -v - | grep -v dev | grep -v a | grep -v b | tail -1 | tr -d '[:space:]')
    echo "Installing Python $latest_python..."
    if ! pyenv install "$latest_python"; then
      echo "ERROR: Python $latest_python failed to install"
      _failed+=("python-$latest_python")
    else
      pyenv global "$latest_python"
    fi
  fi

  if ! command -v zig &>/dev/null; then
    echo "Zig not found, installing..."
    brew install zig
    if ! command -v zig &>/dev/null; then
      echo "ERROR: zig failed to install"
      _failed+=("zig")
    fi
  fi

  if ! command -v nvm &>/dev/null; then
    echo "nvm not found, installing..."
    brew install nvm
    mkdir -p ~/.nvm
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bash_profile
    echo '[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"' >> ~/.bash_profile
    source ~/.bash_profile
    if ! command -v nvm &>/dev/null; then
      echo "ERROR: nvm failed to install"
      _failed+=("nvm")
    fi
  fi

  if command -v nvm &>/dev/null; then
    latest_node=$(nvm ls-remote --lts | tail -1 | awk '{print $1}')
    if [[ -n "$latest_node" ]] && ! nvm ls | grep -q "$latest_node"; then
      echo "Node.js $latest_node not found, installing..."
      if ! nvm install "$latest_node"; then
        echo "ERROR: Node.js $latest_node failed to install"
        _failed+=("node-$latest_node")
      else
        nvm use "$latest_node"
        nvm alias default "$latest_node"
      fi
    fi
  fi

  if ! command -v poetry &>/dev/null; then
    echo "Poetry not found, installing..."
    curl -sSL https://install.python-poetry.org | python3 -
    if ! command -v poetry &>/dev/null; then
      echo "ERROR: poetry failed to install"
      _failed+=("poetry")
    else
      poetry config virtualenvs.in-project true
    fi
  fi

  if ! command -v bun &>/dev/null; then
    echo "Bun not found, installing via Homebrew..."
    brew tap oven-sh/bun
    brew install bun
    if ! command -v bun &>/dev/null; then
      echo "ERROR: bun failed to install"
      _failed+=("bun")
    else
      bun completions
    fi
  fi

  if ! command -v yarn &>/dev/null; then
    echo "Yarn not found, installing via NPM..."
    npm install -g yarn
    if ! command -v yarn &>/dev/null; then
      echo "ERROR: yarn failed to install"
      _failed+=("yarn")
    fi
  fi

  if ! command -v elixir &>/dev/null; then
    echo "Elixir not found, installing via Homebrew..."
    brew install elixir
    if ! command -v elixir &>/dev/null; then
      echo "ERROR: elixir failed to install"
      _failed+=("elixir")
    fi
  fi

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
