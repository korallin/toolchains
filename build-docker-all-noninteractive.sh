#!/bin/bash

docker/noninteractive-build.sh docker/distros/*
ret=$?

docker/rm-all.sh

return $ret
