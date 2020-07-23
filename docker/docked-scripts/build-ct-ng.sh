#!/bin/bash --login
# Use --login to ensure /etc/profile is read

process_list(){
  for path in $* ; do
    if [ -d "$path" ]; then
      process_dir $path
    else
      process_file $path
    fi
  done
}

process_file(){
  local dir=$1
  local dir_rel=".${1:13}"
  local dir_rel_base=$(dirname $dir_rel)
  local dir_rel_name=$(basename $dir_rel)

  cd $dir_rel_base
  ln -s $1 >/dev/null 2>&1
  cd /home/docker_usr/crosstool-ng
}

process_dir(){
  local dir=$1
  local dir_rel=".${1:13}"
  local dir_rel_base=$(dirname $dir_rel)
  local dir_rel_name=$(basename $dir_rel)

  cd $dir_rel_base
  mkdir ./$dir_rel_name
  cd /home/docker_usr/crosstool-ng

  process_list $1/*
}

echo "----Build Ct-Ng"
cd /home/docker_usr 
mkdir ./crosstool-ng 
cd ./crosstool-ng 
cp -rf /crosstool-ng/* .
#process_list /crosstool-ng/*
./bootstrap 
./configure --prefix=/opt/ctng 
make 
make install
