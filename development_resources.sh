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

# git aliases
alias gpnv= 'git push --no-verify'
alias gp=   'git push'
alias gpl=  'git pull'
alias gco=  'git checkout'
alias gcb=  'git checkout -b'
alias gcm=  'git commit -m'
alias gdel= 'git branch -D'

# datadog alias
alias ddog='datadog-js'

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
  # This line checks if the file ~/.gitignore_global exists in the user's home directory
  # If the file exists, the condition evaluates to true and the code inside the if block will execute
  if [ -f ~/.gitignore_global ]; then
    echo "~/.gitignore_global already exists"
    return
  fi

  # copy the .gitignore_global file from $PBR_DIR/extensions/files/.gitignore_global to the user's home directory
  cp $PBR_DIR/extensions/files/.gitignore_global ~/.gitignore_global

  # This line creates a new file called ~/.gitignore_global in the user's home directory
  # If the file does not exist, the condition evaluates to false and the code inside the if block will not execute
  git config --global core.excludesfile ~/.gitignore_global
}

# bun completions
[ -s "/Users/claytonnoyes/.bun/_bun" ] && source "/Users/claytonnoyes/.bun/_bun"
if [ -f "/Users/claytonnoyes/.config/fabric/fabric-bootstrap.inc" ]; then . "/Users/claytonnoyes/.config/fabric/fabric-bootstrap.inc"; fi
