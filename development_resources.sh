# Start the ssh-agent and load your SSH key
echo "Starting the ssh-agent"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# aws
function aws-login {
  profile="$1"
  if [ -z "$profile" ]; then
    echo "Profile is required as first argument."
    return
  fi

  echo "Using SSO account"
  aws sso login --profile "$profile"
  eval "$(aws configure export-credentials --profile "$profile" --format env)"
  export AWS_PROFILE=$profile
  echo "AWS_PROFILE set to $profile"
}

# bash aliases
alias ll='ls -la'
alias rsrc='source ~/.zshrc'

# datadog alias
alias ddog='datadog-js'

# docker aliases
alias dsp='docker system prune'

# git aliases
alias gpnv= 'git push --no-verify'
alias gp=   'git push'
alias gpl=  'git pull'
alias gco=  'git checkout'
alias gcb=  'git checkout -b'
alias gcm=  'git commit -m'
alias gdel= 'git branch -D'

# git functions
function git-update-subfolders() {
  for dir in */; do
    if [[ -d "$dir" && -d "${dir}/.git" ]]; then
      echo "Entering $dir"
      cd "$dir" || continue

      # Determine if the repo uses 'main' or 'master'
      local trunk_branch=$(git rev-parse --abbrev-ref origin/HEAD | sed 's/origin\///')

      # Fetch the latest changes from the remote
      git fetch

      # Save the current branch name
      local current_branch=$(git rev-parse --abbrev-ref HEAD)

      # Check if there are changes to be pulled on the current branch
      if git status -uno | grep -q 'Your branch is behind'; then
        echo "Pulling changes into $current_branch"
        git pull
      else
        echo "$current_branch is up to date."
      fi

      # Switch to the trunk branch if not already there
      if [ "$current_branch" != "$trunk_branch" ]; then
        git checkout "$trunk_branch"
        # Check if there are changes to be pulled on the trunk branch
        if git status -uno | grep -q 'Your branch is behind'; then
          echo "Pulling changes into $trunk_branch"
          git pull
        else
          echo "$trunk_branch is up to date."
        fi
        # Switch back to the original branch
        git checkout "$current_branch"
      fi

      # Go back to the parent directory
      cd - || return
    fi
  done
}

#!/bin/bash

# Function to find all directories with package.json and run yarn install
function install_dependencies() {
    # Check if INSTALL_FOLDERS environment variable is set
    if [ -z "${INSTALL_FOLDERS+x}" ]; then
        echo "INSTALL_FOLDERS environment variable is not set"
        echo "Please set it using: export INSTALL_FOLDERS=(folder1 folder2 folder3)"
        return 1
    fi

    # Check if INSTALL_FOLDERS is an array
    if ! declare -p INSTALL_FOLDERS 2>/dev/null | grep -q 'declare -a'; then
        echo "INSTALL_FOLDERS is not set as an array"
        echo "Please set it using: export INSTALL_FOLDERS=(folder1 folder2 folder3)"
        return 1
    fi

    # Loop through each folder in INSTALL_FOLDERS
    for folder in "${INSTALL_FOLDERS[@]}"; do
        # Check if folder exists in current directory
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

# python aliases
alias python2='python'

function install-global-git-ignore() {
  # Check if the symlink or file already exists
  if [ -e ~/.gitignore_global ]; then
    echo "~/.gitignore_global already exists"
    # Check if it's already a symlink to our file
    if [ -L ~/.gitignore_global ] && [ "$(readlink ~/.gitignore_global)" = "$PBR_DIR/extensions/files/.gitignore_global" ]; then
      echo "It's already correctly symlinked"
      return
    else
      echo "Removing existing file and creating symlink"
      rm ~/.gitignore_global
    fi
  fi

  # Create a symbolic link to the .gitignore_global in the repository
  ln -s "$PBR_DIR/extensions/files/.gitignore_global" ~/.gitignore_global
  echo "Created symlink to global gitignore file"

  # Configure git to use this file
  git config --global core.excludesfile ~/.gitignore_global
  echo "Configured git to use global gitignore file"
}

# bun completions
[ -s "/Users/claytonnoyes/.bun/_bun" ] && source "/Users/claytonnoyes/.bun/_bun"
if [ -f "/Users/claytonnoyes/.config/fabric/fabric-bootstrap.inc" ]; then . "/Users/claytonnoyes/.config/fabric/fabric-bootstrap.inc"; fi
