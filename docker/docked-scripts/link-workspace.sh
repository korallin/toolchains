#!/bin/bash --login
# Use --login to ensure /etc/profile is read

basedir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source ${basedir}/docker_path_consts.sh

cd ${docker_ctng_workspace_dir}
ln -s ${docker_ctng_workspace_ro_dir}/.config >/dev/null 2>&1

cd ${docker_ctng_workspace_dir}/.build/tarballs
for file in ${docker_ctng_tarball_dir}/* ; do
  ln -s $file >/dev/null 2>&1
done
