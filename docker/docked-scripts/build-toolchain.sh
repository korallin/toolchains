#!/bin/bash --login
# Use --login to ensure /etc/profile is read

echo "----Build Toolchain"
cd /home/docker_usr/crosstool-ng-workspace 
ct-ng build
