#!/bin/bash

docker_image_prefix="zoop-"

BASEDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TOPDIR=$(dirname "$BASEDIR")

mkdir -p ${TOPDIR}/.tarball_cache

run_docked() {
docker run --rm -i -t \
    -v ${TOPDIR}/crosstool-ng:/crosstool-ng:ro \
    -v ${TOPDIR}/crosstool-ng-workspace:/home/docker_usr/crosstool-ng-config:ro \
    -v ${BASEDIR}/distros/${dockername}/workspace:/home/docker_usr/crosstool-ng-workspace \
    -v ${BASEDIR}/distros/${dockername}/install:/opt/ctng \
    -v ${BASEDIR}/distros/${dockername}/opt/cross:/opt/cross \
    -v ${BASEDIR}/docked-scripts:/home/docker_usr/docked-scripts:ro \
    -v ${TOPDIR}/.tarball_cache:/home/docker_usr/.tarball_cache \
    ${docker_image_prefix}${dockername} \
    su -l docker_usr -c "/bin/bash --login -c '$*'"
return $?
}
run_docker_build(){

    if [ "$(docker images -q ${docker_image_prefix}${dockername}:latest 2> /dev/null)" == "" ]
    then
        echo "---- $dockernamei needs docker image to be built"
        docker build --no-cache -t ${docker_image_prefix}${dockername} --build-arg USER_ID=`id -g` --build-arg GROUP_ID=`id -u` ${BASEDIR}/distros/${dockername}

        if [ $? -eq 0 ]; then
            echo ---- Build successfull
        else
            echo ---- Build failed
            return 1
        fi
    fi
    
    mkdir -p ${BASEDIR}/distros/${dockername}/workspace
    mkdir -p ${BASEDIR}/distros/${dockername}/install
    mkdir -p ${BASEDIR}/distros/${dockername}/opt/cross
    
    mkdir -p ${BASEDIR}/distros/${dockername}/workspace/.build/tarballs
    run_docked '~/docked-scripts/link-workspace.sh'
    
    if [ ! -f "${BASEDIR}/distros/${dockername}/install/bin/ct-ng" ]
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
    
    config="${TOPDIR}/crosstool-ng-workspace/.config"
    toolchain="${BASEDIR}/distros/${dockername}/opt/cross/bin/*-gcc"
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
    
    
    toolchain="${BASEDIR}/distros/${dockername}/opt/cross/bin/*-gcc"
    toolchain_tar="${BASEDIR}/distros/${dockername}/cross-armv6l-gcc-${dockername}.tar.gz"
    if [ -f $toolchain ] && [ ! $toolchain -ot $toolchain_tar ]
    then
        echo "---- $dockername needs toolchain tar to be assembled"
        echo "tar -caf ${BASEDIR}/distros/${dockername}/cross-armv6l-gcc-${dockername}.tar.gz -C ${BASEDIR}/distros/${dockername} opt/cross"
        tar -caf ${BASEDIR}/distros/${dockername}/cross-armv6l-gcc-${dockername}.tar.gz -C ${BASEDIR}/distros/${dockername} opt/cross
    else
        echo "---- $dockername : Nothing to be done to toolchain tar"
    fi
    
    #docker image save -o ${BASEDIR}/distros/${dockername}/${dockername}.tar ${docker_image_prefix}${dockername}:latest
}

for container in $*
do
    dockername=$(basename $container)
    if [ -d "$BASEDIR/distros/$dockername" ] 
    then
        echo "----$dockername"
        run_docker_build
    else
        dockername=""
        echo "$container is not a managed docker dir"
    fi
done

