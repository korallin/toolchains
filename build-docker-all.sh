#!/bin/bash

docker/build.sh docker/distros/* ctng-workspaces/*
ret=$?

docker/rm-all.sh

exit $ret
