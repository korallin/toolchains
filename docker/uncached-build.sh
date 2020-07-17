#!/bin/bash

docker_image_prefix="zoop-"

BASEDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TOPDIR=$(dirname "$BASEDIR")

mkdir -p ${TOPDIR}/.tarball_cache

run_docked() {
docker run --rm \
    -v ${TOPDIR}/crosstool-ng:/crosstool-ng:ro \
    -v ${TOPDIR}/ctng-workspace-arm-armv6l-linux-gnueabi:/home/docker_usr/ctng-config-arm-armv6l-linux-gnueabi:ro \
    -v ${BASEDIR}/distros/${dockername}/workspace:/home/docker_usr/ctng-workspace-arm-armv6l-linux-gnueabi \
    -v ${BASEDIR}/distros/${dockername}/install:/opt/ctng \
    -v ${BASEDIR}/distros/${dockername}/opt/cross:/opt/cross \
    -v ${BASEDIR}/docked-scripts:/home/docker_usr/docked-scripts:ro \
    -v ${TOPDIR}/.tarball_cache:/home/docker_usr/.tarball_cache \
    ${docker_image_prefix}${dockername} \
    su -l docker_usr -c "/bin/bash --login -c '$*'"
return $?
}
run_docker_build(){

    docker build --no-cache -t ${docker_image_prefix}${dockername} --build-arg USER_ID=1001 --build-arg GROUP_ID=1001 ${BASEDIR}/distros/${dockername}
    if [ $? -eq 0 ]; then
        echo ---- Build successfull
    else
        echo ---- Build failed
        return 1
    fi
    
    mkdir -p ${BASEDIR}/distros/${dockername}/workspace
    mkdir -p ${BASEDIR}/distros/${dockername}/install
    mkdir -p ${BASEDIR}/distros/${dockername}/opt/cross
    
    mkdir -p ${BASEDIR}/distros/${dockername}/workspace/.build/tarballs

    run_docked '~/docked-scripts/link-workspace.sh'
    if [ $? -eq 0 ]; then
        echo ---- Build successfull
    else
        echo ---- Build failed
        return 1
    fi

    run_docked '~/docked-scripts/build-ct-ng.sh'
    if [ $? -eq 0 ]; then
        echo ---- Build successfull
    else
        echo ---- Build failed
        return 1
    fi

    run_docked '~/docked-scripts/build-toolchain.sh'
    if [ $? -eq 0 ]; then
        echo ---- Build successfull
    else
        echo ---- Build failed
        return 1
    fi

    echo "tar -caf ${BASEDIR}/distros/${dockername}/cross-armv6l-gcc-${dockername}.tar.gz -C ${BASEDIR}/distros/${dockername} opt/cross"
    tar -caf ${BASEDIR}/distros/${dockername}/cross-armv6l-gcc-${dockername}.tar.gz -C ${BASEDIR}/distros/${dockername} opt/cross

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
