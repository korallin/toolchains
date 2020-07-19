#!/bin/bash

: # Parameter Expansion
: ${user_id:=`id -g`}
: ${group_id:=`id -u`}
: ${docker_image_prefix:="zoop-"}
: ${docker_run_additional_params:-"-i -t"}

basedir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
topdir=$(dirname "$basedir")

run_docked() {
docker run --rm $docker_run_additional_params \
    -v ${topdir}/crosstool-ng:/crosstool-ng:ro \
    -v ${topdir}/ctng-workspace-arm-armv6l-linux-gnueabi:/home/docker_usr/ctng-config-arm-armv6l-linux-gnueabi:ro \
    -v ${basedir}/distros/${dockername}/workspace:/home/docker_usr/ctng-workspace-arm-armv6l-linux-gnueabi \
    -v ${basedir}/distros/${dockername}/install:/opt/ctng \
    -v ${basedir}/distros/${dockername}/opt/cross:/opt/cross \
    -v ${basedir}/docked-scripts:/home/docker_usr/docked-scripts:ro \
    -v ${topdir}/.tarball_cache:/home/docker_usr/.tarball_cache \
    ${docker_image_prefix}${dockername} \
    su -l docker_usr -c "/bin/bash --login -c '$*'"
return $?
}
run_docker_build(){

    if [ "$(docker images -q ${docker_image_prefix}${dockername}:latest 2> /dev/null)" == "" ]
    then
        echo "---- $dockernamei needs docker image to be built"
        docker build --no-cache -t ${docker_image_prefix}${dockername} --build-arg USER_ID=$user_id --build-arg GROUP_ID=$group_id ${basedir}/distros/${dockername}

        if [ $? -eq 0 ]; then
            echo ---- Build successfull
        else
            echo ---- Build failed
            return 1
        fi
    fi
    
    mkdir -p ${basedir}/distros/${dockername}/workspace
    mkdir -p ${basedir}/distros/${dockername}/install
    mkdir -p ${basedir}/distros/${dockername}/opt/cross
    
    mkdir -p ${basedir}/distros/${dockername}/workspace/.build/tarballs
    run_docked '~/docked-scripts/link-workspace.sh'
    
    if [ ! -f "${basedir}/distros/${dockername}/install/bin/ct-ng" ]
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
    toolchain="${basedir}/distros/${dockername}/opt/cross/bin/*-gcc"
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
    
    
    toolchain="${basedir}/distros/${dockername}/opt/cross/bin/*-gcc"
    toolchain_tar="${basedir}/distros/${dockername}/cross-armv6l-gcc-${dockername}.tar.gz"
    if [ -f $toolchain ] && [ ! $toolchain -ot $toolchain_tar ]
    then
        echo "---- $dockername needs toolchain tar to be assembled"
        echo "tar -caf ${basedir}/distros/${dockername}/cross-armv6l-gcc-${dockername}.tar.gz -C ${basedir}/distros/${dockername} opt/cross"
        tar -caf ${basedir}/distros/${dockername}/cross-armv6l-gcc-${dockername}.tar.gz -C ${basedir}/distros/${dockername} opt/cross
    else
        echo "---- $dockername : Nothing to be done to toolchain tar"
    fi
    
    #docker image save -o ${basedir}/distros/${dockername}/${dockername}.tar ${docker_image_prefix}${dockername}:latest
}

mkdir -p ${topdir}/.tarball_cache

for container in $*
do
    dockername=$(basename $container)
    if [ -d "$basedir/distros/$dockername" ] 
    then
        echo "----$dockername"
        run_docker_build
    else
        dockername=""
        echo "$container is not a managed docker dir"
    fi
done

