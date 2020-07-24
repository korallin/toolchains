#!/bin/bash --login
# Use --login to ensure /etc/profile is read

basedir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source ${basedir}/docker_path_consts.sh

echo "----Build Ct-Ng"
cd /home/docker_usr 
mkdir ./crosstool-ng 
cd ./crosstool-ng 
cp -rf ${docker_ctng_source_dir}/* .
./bootstrap 
./configure --prefix=/opt/ctng 
make 
make install
