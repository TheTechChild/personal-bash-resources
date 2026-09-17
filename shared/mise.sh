#!/bin/bash
# mise (https://mise.jdx.dev) — one version manager for every language.
#
# PBR uses mise in place of nvm, pyenv, and rbenv. mise reads
# .tool-versions, mise.toml, .nvmrc, .node-version, .ruby-version, and
# .python-version, so it understands the files the old managers used.
#
# Platform env.sh calls pbr-mise-activate AFTER it sets PATH, so that the
# mise shims stay in front of the system and Homebrew directories.

pbr-mise-activate() {
  command -v mise &>/dev/null || return 0

  local _shell
  if [ -n "$ZSH_VERSION" ]; then
    _shell="zsh"
  elif [ -n "$BASH_VERSION" ]; then
    _shell="bash"
  else
    return 0
  fi

  eval "$(mise activate "$_shell")"
}

# Languages that `install_development_languages` installs on every platform.
# Add a tool here and both macOS and Arch get it.
PBR_MISE_LANGUAGES=(ruby python node zig elixir bun poetry yarn)

# Install each tool in PBR_MISE_LANGUAGES that mise does not have yet.
# Appends the name of each failure to the caller's _failed array.
_pbr_mise_install_languages() {
  local tool

  if ! command -v mise &>/dev/null; then
    echo "ERROR: mise not found. Install it first."
    return 1
  fi

  # Make mise read .nvmrc, .node-version, .ruby-version, and .python-version.
  # mise reads .tool-versions and mise.toml always, but these files are opt-in.
  mise settings idiomatic_version_file_enable_tools=node,ruby,python

  for tool in "${PBR_MISE_LANGUAGES[@]}"; do
    if [[ -n "$(mise ls --installed "$tool" 2>/dev/null)" ]]; then
      continue
    fi
    echo "$tool not found, installing the latest version with mise..."
    if ! mise use --global "$tool@latest"; then
      echo "ERROR: $tool failed to install"
      _failed+=("$tool")
    fi
  done
}
