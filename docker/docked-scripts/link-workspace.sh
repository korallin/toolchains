#!/bin/bash --login
# Use --login to ensure /etc/profile is read

cd /home/docker_usr/crosstool-ng-workspace/
ln -s /home/docker_usr/crosstool-ng-config/.config >/dev/null 2>&1

cd /home/docker_usr/crosstool-ng-workspace/.build/tarballs
for file in /home/docker_usr/.tarball_cache/* ; do
    ln -s $file >/dev/null 2>&1
done
