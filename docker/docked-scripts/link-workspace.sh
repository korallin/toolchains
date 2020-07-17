#!/bin/bash --login
# Use --login to ensure /etc/profile is read

cd /home/docker_usr/crosstool-ng-workspace/
ln -s /home/docker_usr/crosstool-ng-config/.config

cd /home/docker_usr/crosstool-ng-workspace/.build/tarballs
for file in /home/docker_usr/src/* ; do
    ln -s $file 2>&1
done
