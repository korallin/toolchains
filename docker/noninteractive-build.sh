#!/bin/bash

basedir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

user_id=1001 group_id=1001 docker_run_additional_params="" $basedir/build.sh $*
