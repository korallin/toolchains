#!/bin/bash

docker/uncached-build.sh docker/distros/*
docker/rm-all.sh
