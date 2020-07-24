#!/bin/bash

cat ./toolchains-release.yml.model.prefix > toolchains-release.yml

for workspace in ../../docker/distros/*
do
  for distro in ../../ctng-workspaces//*
  do
    distro_id=$(basename $distro)
    workspace_id=$(basename $workspace)
    job_name=$(echo $distro_id | sed 's:\.:_:')_$(echo $workspace_id | sed 's:\.:_:')
    cat ./toolchains-release.yml.model.job | sed "s:!!!_name_!!!:$job_name:" | sed "s:!!!_distro_!!!:$distro_id:" | sed "s:!!!_workspace_!!!:$workspace_id:" >> toolchains-release.yml
  done
done
