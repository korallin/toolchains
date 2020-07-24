#!/bin/bash --login
# Use --login to ensure /etc/profile is read

basedir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source ${basedir}/docker_path_consts.sh

echo "----Build Toolchain"
cd ${docker_ctng_workspace_dir}
ct-ng build
