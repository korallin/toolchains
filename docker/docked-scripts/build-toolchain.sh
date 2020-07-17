#!/bin/bash --login
# Use --login to ensure /etc/profile is read

echo "----Build Toolchain"
cd /home/docker_usr/ctng-workspace-arm-armv6l-linux-gnueabi 
ct-ng build
