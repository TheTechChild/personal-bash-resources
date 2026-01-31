#!/bin/bash

install_development_languages() {
  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ $(uname -m) == "arm64" ]]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    echo "Homebrew installed successfully"
  fi

  if ! command -v rbenv &> /dev/null; then
    echo "rbenv not found, installing..."
    brew install rbenv
    rbenv init
    eval "$(rbenv init -)"
  fi

  latest_ruby=$(rbenv install -l | grep -v - | tail -1)
  if ! rbenv versions | grep -q "$latest_ruby"; then
    echo "Ruby $latest_ruby not found, installing..."
    rbenv install "$latest_ruby"
    rbenv global "$latest_ruby"
  fi

  if ! command -v pyenv &> /dev/null; then
    echo "pyenv not found, installing..."
    brew install pyenv
    eval "$(pyenv init -)"
  fi

  if ! command -v python3 &> /dev/null; then
    echo "Python3 not found, installing..."
    latest_python=$(pyenv install --list | grep -v - | grep -v dev | grep -v a | grep -v b | tail -1 | tr -d '[:space:]')
    echo "Installing Python $latest_python..."
    pyenv install "$latest_python"
    pyenv global "$latest_python"
  fi

  if ! command -v zig &> /dev/null; then
    echo "Zig not found, installing..."
    brew install zig
  fi

  if ! command -v nvm &> /dev/null; then
    echo "nvm not found, installing..."
    brew install nvm
    mkdir -p ~/.nvm
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bash_profile
    echo '[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"' >> ~/.bash_profile
    source ~/.bash_profile
  fi

  latest_node=$(nvm ls-remote --lts | tail -1 | awk '{print $1}')
  if ! nvm ls | grep -q "$latest_node"; then
    echo "Node.js $latest_node not found, installing..."
    nvm install "$latest_node"
    nvm use "$latest_node"
    nvm alias default "$latest_node"
  fi

  if ! command -v poetry &> /dev/null; then
    echo "Poetry not found, installing..."
    curl -sSL https://install.python-poetry.org | python3 -
    poetry config virtualenvs.in-project true
  fi

  if ! command -v bun &> /dev/null; then
    echo "Bun not found, installing via Homebrew..."
    brew tap oven-sh/bun
    brew install bun
    bun completions
    echo "Bun installed successfully"
  fi

  if ! command -v yarn &> /dev/null; then
    echo "Yarn not found, installing via NPM..."
    npm install -g yarn
    echo "Yarn installed successfully"
  fi

  if ! command -v elixir &> /dev/null; then
    echo "Elixir not found, installing via Homebrew..."
    brew install elixir
    echo "Elixir installed successfully"
  fi
}

install_development_tools() {
  if ! command -v opencode &> /dev/null; then
    echo "OpenCode CLI not found, installing..."
    curl -fsSL https://opencode.ai/install | bash
    npm install -g oh-my-opencode@latest
    echo "OpenCode CLI installed successfully"
  fi

  if ! [ -d "/Applications/Visual Studio Code.app" ]; then
    echo "VS Code not found, installing..."
    brew install --cask visual-studio-code
    echo "VS Code installed successfully"
  fi

  if ! command -v nvim &> /dev/null; then
    echo "Neovim not found, installing..."
    brew install neovim
    echo "Neovim installed successfully"
  fi

  if ! [ -d "/Applications/iTerm.app" ]; then
    echo "iTerm2 not found, installing..."
    brew install --cask iterm2
    echo "iTerm2 installed successfully"
  fi

  if ! command -v gtimeout &> /dev/null; then
    echo "coreutils not found, installing..."
    brew install coreutils
    sudo ln -s /usr/local/bin/gtimeout /usr/local/bin/timeout
    echo "coreutils installed successfully"
  fi

  if ! command -v java &> /dev/null; then
    echo "Java not found, installing..."
    brew install openjdk@17
    echo "Java installed successfully"
  fi
}

install_macos_utilities() {
  if ! [ -d "/Applications/MonitorControl.app" ]; then
    echo "MonitorControl not found, installing..."
    brew install --cask monitorcontrol
    echo "MonitorControl installed successfully"
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
}
