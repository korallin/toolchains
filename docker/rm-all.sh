#!/bin/bash

basedir=`dirname "$0"`
docker_image_prefix="zoop-"

if [ "$1" == "all" ] 
then
    for c in `docker ps -a -q`
    do
        docker rm $c
    done
    for i in `docker images -q`
    do
        docker rmi --force $i
    done
else
    for c in `docker ps -a -q`
    do
        docker rm $c
    done
    for d in $basedir/distros/*
    do
        if [ -d $d ]
        then
            i=$docker_image_prefix`basename $d`
            docker rmi --force $i
        fi
    done
fi

