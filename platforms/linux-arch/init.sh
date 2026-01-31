#!/bin/bash

local_platform_dir="$PBR_DIR/platforms/linux-arch"

source "$local_platform_dir/env.sh"
source "$local_platform_dir/path.sh"
source "$local_platform_dir/ssh.sh"
source "$local_platform_dir/install.sh"
source "$local_platform_dir/gaming.sh"

unset local_platform_dir
