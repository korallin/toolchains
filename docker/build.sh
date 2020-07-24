#!/bin/bash

: # Parameter Expansion
: ${user_id:=`id -g`}
: ${group_id:=`id -u`}
: ${docker_image_prefix:="zoop-"}
: ${docker_run_additional_params:-"-i -t"}

basedir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
topdir=$(dirname "$basedir")

source ${basedir}/docked-scripts/docker_path_consts.sh

run_docked() {
  docker run --rm $docker_run_additional_params \
    -v ${topdir}/crosstool-ng:${docker_ctng_source_dir}:ro \
    -v ${topdir}/ctng-workspaces/${workspace}:${docker_ctng_workspace_ro_dir}:ro \
    -v ${curr_workspace_dir}/workspace:${docker_ctng_workspace_dir} \
    -v ${curr_workspace_dir}/install:${docker_ctng_dir} \
    -v ${curr_workspace_dir}/opt/cross:${docker_toolchain_install_dir} \
    -v ${basedir}/docked-scripts:${docker_ctng_scripts_dir}:ro \
    -v ${topdir}/.tarball_cache:${docker_ctng_tarball_dir} \
    ${docker_image_prefix}${dockername} \
    su -l docker_usr -c "/bin/bash --login -c '$*'"
  return $?
}
run_docker_build(){

  mkdir -p ${curr_workspace_dir}

  if [ "$(docker images -q ${docker_image_prefix}${dockername}:latest 2> /dev/null)" == "" ]
  then
    echo "---- $dockernamei needs docker image to be built"
    echo docker build --no-cache -t ${docker_image_prefix}${dockername} --build-arg USER_ID=$user_id --build-arg GROUP_ID=$group_id ${curr_workspace_dir}
    docker build --no-cache -t ${docker_image_prefix}${dockername} --build-arg USER_ID=$user_id --build-arg GROUP_ID=$group_id ${curr_workspace_dir}

    if [ $? -eq 0 ]; then
      echo ---- Build successfull
    else
      echo ---- Build failed
      return 1
    fi
  fi

  mkdir -p ${curr_workspace_dir}/workspace
  mkdir -p ${curr_workspace_dir}/install
  mkdir -p ${curr_workspace_dir}/opt/cross

  mkdir -p ${curr_workspace_dir}/workspace/.build/tarballs
  run_docked '~/docked-scripts/link-workspace.sh'

  if [ ! -f "${curr_workspace_dir}/install/bin/ct-ng" ]
  then
    echo "---- $dockername needs ct-ng to be built"
    run_docked '~/docked-scripts/build-ct-ng.sh'
    if [ $? -eq 0 ]; then
      echo ---- Build successfull
    else
      echo ---- Build failed
      return 1
    fi
  else
    echo "---- $dockername : Nothing to be done to ct-ng bin"
  fi

  config="${topdir}/ctng-workspace-arm-armv6l-linux-gnueabi/.config"
  toolchain="${curr_workspace_dir}/opt/cross/bin/*-gcc"
  if [ ! $config -ot $toolchain ]
  then
    echo "---- $dockername needs toolchain to be built"
    run_docked '~/docked-scripts/build-toolchain.sh'
    if [ $? -eq 0 ]; then
      echo ---- Build successfull
    else
      echo ---- Build failed
      return 1
    fi
  else
    echo "---- $dockername : Nothing to be done to toolchain"
  fi


  toolchain="${curr_workspace_dir}/opt/cross/bin/*-gcc"
  toolchain_tar="${curr_workspace_dir}/${workspace}-${dockername}.tar.gz"
  if [ -f $toolchain ] && [ ! $toolchain -ot $toolchain_tar ]
  then
    echo "---- $dockername needs toolchain tar to be assembled"
    echo "tar -caf ${toolchain_tar} -C ${curr_workspace_dir} opt/cross"
    tar -caf ${toolchain_tar} -C ${curr_workspace_dir} opt/cross
  else
    echo "---- $dockername : Nothing to be done to toolchain tar"
  fi

  #docker image save -o ${basedir}/distros/${dockername}/${dockername}.tar ${docker_image_prefix}${dockername}:latest
}

mkdir -p ${topdir}/.tarball_cache 2>/dev/null

for dir in $*
do
  dir_name=$(basename $dir)
  if [ -d "$basedir/distros/$dir_name" ] 
  then
    docker_list=("${docker_list[@]}" "$dir_name") 
  elif [ -d "$topdir/ctng-workspaces/$dir_name" ]
  then
    workspace_list=("${workspace_list[@]}" "$dir_name")
  else
    echo "Warning!"
    echo "$dir_name is not a managed docker dir nor a workspace"
  fi
done

for workspace in $workspace_list
do
  for dockername in $docker_list
  do
    curr_workspace_dir=${basedir}/distros/${dockername}/${workspace}
    run_docker_build
  done
done
