#!/bin/bash

_arch_check_helper() {
  if command -v paru &>/dev/null; then
    echo "paru"
  elif command -v yay &>/dev/null; then
    echo "yay"
  else
    echo ""
  fi
}

_arch_pkg_install() {
  local helper
  helper=$(_arch_check_helper)
  if [[ -n "$helper" ]]; then
    "$helper" -S --needed --noconfirm "$@"
  else
    sudo pacman -S --needed --noconfirm "$@"
  fi
}

_arch_aur_install() {
  local helper
  helper=$(_arch_check_helper)
  if [[ -z "$helper" ]]; then
    echo "ERROR: No AUR helper (paru/yay) found. Install paru first via arch-setup-base."
    return 1
  fi
  "$helper" -S --needed --noconfirm "$@"
}

install_development_languages() {
  echo "Installing development languages via pacman..."

  if ! command -v git &>/dev/null; then
    sudo pacman -S --needed --noconfirm base-devel git
  fi

  if ! command -v rbenv &>/dev/null; then
    echo "rbenv not found, installing..."
    _arch_pkg_install rbenv ruby-build
    eval "$(rbenv init -)"
  fi

  latest_ruby=$(rbenv install -l | grep -v - | tail -1)
  if ! rbenv versions | grep -q "$latest_ruby"; then
    echo "Ruby $latest_ruby not found, installing..."
    rbenv install "$latest_ruby"
    rbenv global "$latest_ruby"
  fi

  if ! command -v pyenv &>/dev/null; then
    echo "pyenv not found, installing..."
    _arch_pkg_install pyenv base-devel openssl zlib xz tk
    eval "$(pyenv init -)"
  fi

  if ! command -v python3 &>/dev/null; then
    echo "Python3 not found, installing..."
    latest_python=$(pyenv install --list | grep -v - | grep -v dev | grep -v a | grep -v b | tail -1 | tr -d '[:space:]')
    echo "Installing Python $latest_python..."
    pyenv install "$latest_python"
    pyenv global "$latest_python"
  fi

  if ! command -v zig &>/dev/null; then
    echo "Zig not found, installing..."
    _arch_pkg_install zig
  fi

  if [[ ! -s /usr/share/nvm/init-nvm.sh && ! -s "$NVM_DIR/nvm.sh" ]]; then
    echo "nvm not found, installing..."
    _arch_pkg_install nvm
    source /usr/share/nvm/init-nvm.sh
  fi

  latest_node=$(nvm ls-remote --lts | tail -1 | awk '{print $1}')
  if ! nvm ls | grep -q "$latest_node"; then
    echo "Node.js $latest_node not found, installing..."
    nvm install "$latest_node"
    nvm use "$latest_node"
    nvm alias default "$latest_node"
  fi

  if ! command -v poetry &>/dev/null; then
    echo "Poetry not found, installing..."
    _arch_pkg_install python-poetry
    poetry config virtualenvs.in-project true
  fi

  if ! command -v bun &>/dev/null; then
    echo "Bun not found, installing..."
    _arch_pkg_install bun
    echo "Bun installed successfully"
  fi

  if ! command -v yarn &>/dev/null; then
    echo "Yarn not found, installing..."
    _arch_pkg_install yarn
    echo "Yarn installed successfully"
  fi

  if ! command -v elixir &>/dev/null; then
    echo "Elixir not found, installing..."
    _arch_pkg_install elixir
    echo "Elixir installed successfully"
  fi
}

install_development_tools() {
  if ! command -v opencode &>/dev/null; then
    echo "OpenCode CLI not found, installing..."
    _arch_aur_install opencode
    npm install -g oh-my-opencode@latest
    echo "OpenCode CLI installed successfully"
  fi

  if ! command -v code &>/dev/null; then
    echo "VS Code not found, installing from AUR..."
    _arch_aur_install visual-studio-code-bin
    echo "VS Code installed successfully"
  fi

  if ! command -v nvim &>/dev/null; then
    echo "Neovim not found, installing..."
    _arch_pkg_install neovim
    echo "Neovim installed successfully"
  fi

  if ! command -v java &>/dev/null; then
    echo "OpenJDK 17 not found, installing..."
    _arch_pkg_install jdk17-openjdk
    sudo archlinux-java set java-17-openjdk
    echo "Java installed successfully"
  fi

  if ! command -v docker &>/dev/null; then
    echo "Docker not found, installing..."
    _arch_pkg_install docker docker-compose
    sudo systemctl enable --now docker.service
    sudo usermod -aG docker "$USER"
    echo "Docker installed successfully"
    echo "NOTE: Log out and back in for docker group to take effect"
  fi
}
