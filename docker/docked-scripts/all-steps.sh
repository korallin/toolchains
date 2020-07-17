#!/bin/bash --login
# Use --login to ensure /etc/profile is read
./link-workspace.sh
./build-ct-ng.sh
./build-toolchain.sh
