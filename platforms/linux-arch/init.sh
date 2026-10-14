#!/bin/bash

local_platform_dir="$PBR_DIR/platforms/linux-arch"

source "$local_platform_dir/env.sh"
source "$local_platform_dir/path.sh"

# mise is in ~/.local/bin, which path.sh adds. Activate mise after path.sh,
# so that the shell finds mise and the mise shims stay in front of the other
# directories. See shared/mise.sh.
pbr-mise-activate

source "$local_platform_dir/ssh.sh"
source "$local_platform_dir/install.sh"
source "$local_platform_dir/gaming.sh"

unset local_platform_dir
