#!/bin/bash

docker/build.sh docker/distros/*
docker/rm-all.sh
