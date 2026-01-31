#!/bin/bash

function git-update-subfolders() {
  local pids=()

  for dir in */; do
    if [[ -d "$dir" && -d "${dir}/.git" ]]; then
      (
        cd "$dir" || exit

        local trunk_branch=$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's/origin\///')
        if [[ -z "$trunk_branch" || "$trunk_branch" == "HEAD" ]]; then
          if git show-ref --verify --quiet refs/heads/main; then
            trunk_branch="main"
          else
            trunk_branch="master"
          fi
        fi

        git fetch --prune --quiet

        local current_branch=$(git rev-parse --abbrev-ref HEAD)

        if git status -uno | grep -q 'Your branch is behind'; then
          git pull --ff-only --quiet && echo "$dir: pulled $current_branch"
        fi

        if [[ "$current_branch" != "$trunk_branch" ]]; then
          git fetch origin "$trunk_branch:$trunk_branch" 2>/dev/null && echo "$dir: updated $trunk_branch"
        fi
      ) &
      pids+=($!)
    fi
  done

  for pid in "${pids[@]}"; do
    wait "$pid"
  done

  echo "All repos updated."
}

function git-update-subfolders-sequential() {
  for dir in */; do
    if [[ -d "$dir" && -d "${dir}/.git" ]]; then
      echo "Entering $dir"
      cd "$dir" || continue

      local trunk_branch=$(git rev-parse --abbrev-ref origin/HEAD | sed 's/origin\///')

      git fetch

      local current_branch=$(git rev-parse --abbrev-ref HEAD)

      if git status -uno | grep -q 'Your branch is behind'; then
        echo "Pulling changes into $current_branch"
        git pull
      else
        echo "$current_branch is up to date."
      fi

      if [ "$current_branch" != "$trunk_branch" ]; then
        git checkout "$trunk_branch"
        if git status -uno | grep -q 'Your branch is behind'; then
          echo "Pulling changes into $trunk_branch"
          git pull
        else
          echo "$trunk_branch is up to date."
        fi
        git checkout "$current_branch"
      fi

      cd - || return
    fi
  done
}

function install_dependencies() {
    if [ -z "${INSTALL_FOLDERS+x}" ]; then
        echo "INSTALL_FOLDERS environment variable is not set"
        echo "Please set it using: export INSTALL_FOLDERS=(folder1 folder2 folder3)"
        return 1
    fi

    if ! declare -p INSTALL_FOLDERS 2>/dev/null | grep -q 'declare -a'; then
        echo "INSTALL_FOLDERS is not set as an array"
        echo "Please set it using: export INSTALL_FOLDERS=(folder1 folder2 folder3)"
        return 1
    fi

    for folder in "${INSTALL_FOLDERS[@]}"; do
        if [ -d "$folder" ]; then
            echo "Installing dependencies in $folder"
            if [ -f "$folder/package.json" ]; then
                (cd "$folder" && yarn install)
            else
                echo "No package.json found in $folder"
            fi
        else
            echo "Folder $folder does not exist in current directory"
        fi
    done
}

function install-global-git-ignore() {
  if [ -e ~/.gitignore_global ]; then
    echo "~/.gitignore_global already exists"
    if [ -L ~/.gitignore_global ] && [ "$(readlink ~/.gitignore_global)" = "$PBR_DIR/extensions/files/.gitignore_global" ]; then
      echo "It's already correctly symlinked"
      return
    else
      echo "Removing existing file and creating symlink"
      rm ~/.gitignore_global
    fi
  fi

  ln -s "$PBR_DIR/extensions/files/.gitignore_global" ~/.gitignore_global
  echo "Created symlink to global gitignore file"

  git config --global core.excludesfile ~/.gitignore_global
  echo "Configured git to use global gitignore file"
}
