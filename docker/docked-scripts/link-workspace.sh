#!/bin/bash --login
# Use --login to ensure /etc/profile is read

cd /home/docker_usr/ctng-workspace-arm-armv6l-linux-gnueabi/
ln -s /home/docker_usr/ctng-config-arm-armv6l-linux-gnueabi/.config >/dev/null 2>&1

cd /home/docker_usr/ctng-workspace-arm-armv6l-linux-gnueabi/.build/tarballs
for file in /home/docker_usr/.tarball_cache/* ; do
  ln -s $file >/dev/null 2>&1
done
