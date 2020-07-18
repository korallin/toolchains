#!/bin/bash

docker/noninteractive-build.sh docker/distros/*
docker/rm-all.sh
