#!/bin/bash

docker/build.sh docker/distros/*
ret=$?

docker/rm-all.sh

return $ret
