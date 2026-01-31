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
  local _failed=()

  if ! command -v git &>/dev/null; then
    sudo pacman -S --needed --noconfirm base-devel git
    if ! command -v git &>/dev/null; then
      echo "ERROR: git failed to install"
      _failed+=("git")
      return 1
    fi
  fi

  if ! command -v rbenv &>/dev/null; then
    echo "rbenv not found, installing..."
    _arch_pkg_install rbenv ruby-build
    if ! command -v rbenv &>/dev/null; then
      echo "ERROR: rbenv failed to install"
      _failed+=("rbenv")
    else
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
    _arch_pkg_install pyenv base-devel openssl zlib xz tk
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
    _arch_pkg_install zig
    if ! command -v zig &>/dev/null; then
      echo "ERROR: zig failed to install"
      _failed+=("zig")
    fi
  fi

  if [[ ! -s /usr/share/nvm/init-nvm.sh && ! -s "$NVM_DIR/nvm.sh" ]]; then
    echo "nvm not found, installing..."
    _arch_pkg_install nvm
    if [[ -s /usr/share/nvm/init-nvm.sh ]]; then
      source /usr/share/nvm/init-nvm.sh
    else
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
    _arch_pkg_install python-poetry
    if ! command -v poetry &>/dev/null; then
      echo "ERROR: poetry failed to install"
      _failed+=("poetry")
    else
      poetry config virtualenvs.in-project true
    fi
  fi

  if ! command -v bun &>/dev/null; then
    echo "Bun not found, installing..."
    _arch_pkg_install bun
    if ! command -v bun &>/dev/null; then
      echo "ERROR: bun failed to install"
      _failed+=("bun")
    fi
  fi

  if ! command -v yarn &>/dev/null; then
    echo "Yarn not found, installing..."
    _arch_pkg_install yarn
    if ! command -v yarn &>/dev/null; then
      echo "ERROR: yarn failed to install"
      _failed+=("yarn")
    fi
  fi

  if ! command -v elixir &>/dev/null; then
    echo "Elixir not found, installing..."
    _arch_pkg_install elixir
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
    _arch_aur_install opencode
    if command -v opencode &>/dev/null; then
      npm install -g oh-my-opencode@latest
    else
      echo "ERROR: opencode failed to install"
      _failed+=("opencode")
    fi
  fi

  if ! command -v code &>/dev/null; then
    echo "VS Code not found, installing from AUR..."
    _arch_aur_install visual-studio-code-bin
    if ! command -v code &>/dev/null; then
      echo "ERROR: VS Code failed to install"
      _failed+=("vscode")
    fi
  fi

  if ! command -v nvim &>/dev/null; then
    echo "Neovim not found, installing..."
    _arch_pkg_install neovim
    if ! command -v nvim &>/dev/null; then
      echo "ERROR: neovim failed to install"
      _failed+=("neovim")
    fi
  fi

  if ! command -v java &>/dev/null; then
    echo "OpenJDK 17 not found, installing..."
    _arch_pkg_install jdk17-openjdk
    if ! command -v java &>/dev/null; then
      echo "ERROR: java failed to install"
      _failed+=("java")
    else
      sudo archlinux-java set java-17-openjdk
    fi
  fi

  if ! command -v docker &>/dev/null; then
    echo "Docker not found, installing..."
    _arch_pkg_install docker docker-compose
    if ! command -v docker &>/dev/null; then
      echo "ERROR: docker failed to install"
      _failed+=("docker")
    else
      sudo systemctl enable --now docker.service
      sudo usermod -aG docker "$USER"
      echo "NOTE: Log out and back in for docker group to take effect"
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
