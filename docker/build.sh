BASEDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TOPDIR=$(dirname "$BASEDIR")

#dockername=alpine3.8

mkdir -p ${TOPDIR}/.tarball_cache

run_docked() {
docker run --rm -i -t \
    -v ${TOPDIR}/crosstool-ng:/crosstool-ng:ro \
    -v ${TOPDIR}/crosstool-ng-workspace:/home/docker_usr/crosstool-ng-config:ro \
    -v ${BASEDIR}/distros/${dockername}/workspace:/home/docker_usr/crosstool-ng-workspace \
    -v ${BASEDIR}/distros/${dockername}/install:/opt/ctng \
    -v ${BASEDIR}/distros/${dockername}/opt/cross:/opt/cross \
    -v ${BASEDIR}/docked-scripts:/home/docker_usr/docked-scripts:ro \
    -v ${TOPDIR}/.tarball_cache:/home/docker_usr/src \
    zoop-${dockername} \
    su -l docker_usr -c "/bin/bash --login -c '$*'"
}
run_docker_build(){

if [ "$(docker images -q zoop-${dockername}:latest 2> /dev/null)" == "" ]; then
    echo "---- $dockernamei needs docker image to be built"
    docker build --no-cache -t zoop-${dockername} --build-arg USER_ID=`id -g` --build-arg GROUP_ID=`id -u` ${BASEDIR}/distros/${dockername}
fi

mkdir -p ${BASEDIR}/distros/${dockername}/workspace
mkdir -p ${BASEDIR}/distros/${dockername}/install
mkdir -p ${BASEDIR}/distros/${dockername}/opt/cross

mkdir -p ${BASEDIR}/distros/${dockername}/workspace/.build/tarballs
run_docked '~/docked-scripts/link-workspace.sh'

if [ ! -f "${BASEDIR}/distros/${dockername}/install/bin/ct-ng" ]; then
    echo "---- $dockername needs ct-ng to be built"
    run_docked '~/docked-scripts/build-ct-ng.sh'
else
    echo "---- $dockername : Nothing to be done to ct-ng bin"
fi

if [ "${TOPDIR}/crosstool-ng-workspace/.config" -ot "${BASEDIR}/distros/${dockername}/opt/cross/bin/*-gcc" ]; then
    echo "---- $dockername : Nothing to be done to toolchain"
else
    echo "---- $dockername needs toolchain to be built"
    run_docked '~/docked-scripts/build-toolchain.sh'
fi

echo ---- Making Toolchain Tar
echo "tar -caf cross-armv6l-gcc-${dockername}.tar.gz -C ${BASEDIR}/distros/${dockername} opt/cross"
tar -caf cross-armv6l-gcc-${dockername}.tar.gz -C ${BASEDIR}/distros/${dockername} opt/cross

}

for container in $*; do
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

