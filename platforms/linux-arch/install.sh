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
  echo "Installing development languages via mise..."
  local _failed=()

  if ! command -v git &>/dev/null; then
    sudo pacman -S --needed --noconfirm base-devel git
    if ! command -v git &>/dev/null; then
      echo "ERROR: git failed to install"
      _failed+=("git")
      return 1
    fi
  fi

  if ! command -v mise &>/dev/null; then
    echo "mise not found, installing..."
    _arch_pkg_install mise
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
