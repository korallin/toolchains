#!/bin/bash
cat ./toolchains-release.yml.model.prefix > toolchains-release.yml
for distros in ../../docker/distros/*
do
    distro_id=$(basename $distros)
    distro_safe_name=$(echo $distro_id | sed 's:\.:_:')
    cat ./toolchains-release.yml.model.job | sed "s:!!!_name_!!!:$distro_safe_name:" | sed "s:!!!_id_!!!:$distro_id:" >> toolchains-release.yml
done
