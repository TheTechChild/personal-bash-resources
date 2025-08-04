#!/bin/bash

# Environment Setup
export NVM_DIR=~/.nvm
export LDFLAGS="-L/opt/homebrew/opt/postgresql@15/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@15/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@15/lib/pkgconfig"
export PYENV_ROOT="$HOME/.penv"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="/Users/$USER/Library/pnpm"
[ -s "/Users/claytonnoyes/.bun/_bun" ] && source "/Users/claytonnoyes/.bun/_bun"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# rbenv setup
eval "$(rbenv init -)"

# nvm setup
source $(brew --prefix nvm)/nvm.sh

# Terraform setup
alias tf="terraform"

install_development_languages() {
  # Check and install Homebrew
  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH based on processor architecture
    if [[ $(uname -m) == "arm64" ]]; then
      # For Apple Silicon
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      # For Intel Macs
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    echo "Homebrew installed successfully"
  fi

  # Check and install Ruby via rbenv
  if ! command -v rbenv &> /dev/null; then
    echo "rbenv not found, installing..."
    brew install rbenv
    rbenv init
    eval "$(rbenv init -)"
  fi

  # Install the latest stable Ruby version
  latest_ruby=$(rbenv install -l | grep -v - | tail -1)
  if ! rbenv versions | grep -q "$latest_ruby"; then
    echo "Ruby $latest_ruby not found, installing..."
    rbenv install "$latest_ruby"
    rbenv global "$latest_ruby"
  fi

  # Check and install pyenv
  if ! command -v pyenv &> /dev/null; then
    echo "pyenv not found, installing..."
    brew install pyenv
    eval "$(pyenv init -)"
  fi

  # Check and install Python3 via pyenv
  if ! command -v python3 &> /dev/null; then
    echo "Python3 not found, installing..."
    latest_python=$(pyenv install --list | grep -v - | grep -v dev | grep -v a | grep -v b | tail -1 | tr -d '[:space:]')
    echo "Installing Python $latest_python..."
    pyenv install "$latest_python"
    pyenv global "$latest_python"
  fi

  # Check and install Zig via brew
  if ! command -v zig &> /dev/null; then
    echo "Zig not found, installing..."
    brew install zig
  fi

  # Check and install Node.js via nvm
  if ! command -v nvm &> /dev/null; then
    echo "nvm not found, installing..."
    brew install nvm
    mkdir ~/.nvm
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

  # Check and install Poetry
  if ! command -v poetry &> /dev/null; then
    echo "Poetry not found, installing..."
    curl -sSL https://install.python-poetry.org | python3 -
    # Configure Poetry to create virtual environments in the project directory
    poetry config virtualenvs.in-project true
  fi

  # Check and install Bun via Homebrew
  if ! command -v bun &> /dev/null; then
    echo "Bun not found, installing via Homebrew..."
    brew tap oven-sh/bun
    brew install bun
    
    # Add shell completions
    bun completions
    
    echo "Bun installed successfully"
  fi

  # Check and install yarn via NPM
  if ! command -v yarn &> /dev/null; then
    echo "Yarn not found, installing via NPM..."
    npm install -g yarn
    echo "Yarn installed successfully"
  fi

  # Check and install Elixir via Homebrew
  if ! command -v elixir &> /dev/null; then
    echo "Elixir not found, installing via Homebrew..."
    brew install elixir
    
    echo "Elixir installed successfully"
  fi
}

# Install development tools (Claude Code, Cursor, Neovim, iTerm2)
install_development_tools() {
  # Check and install Claude Code CLI
  if ! command -v claude &> /dev/null; then
    echo "Claude Code CLI not found, installing..."
    brew install claude
    echo "Claude Code CLI installed successfully"
  fi

  # Check and install Cursor
  if ! command -v cursor &> /dev/null; then
    echo "Cursor not found, installing..."
    brew install --cask cursor
    echo "Cursor installed successfully"
  fi

  # Check and install Neovim
  if ! command -v nvim &> /dev/null; then
    echo "Neovim not found, installing..."
    brew install neovim
    echo "Neovim installed successfully"
  fi

  # Check and install iTerm2
  if ! [ -d "/Applications/iTerm.app" ]; then
    echo "iTerm2 not found, installing..."
    brew install --cask iterm2
    echo "iTerm2 installed successfully"
  fi
}
