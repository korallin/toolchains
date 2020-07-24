#!/bin/bash

docker/noninteractive-build.sh docker/distros/* ctng-workspaces/*
ret=$?

docker/rm-all.sh

exit $ret
