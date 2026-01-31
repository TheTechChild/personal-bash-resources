#!/bin/bash

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
