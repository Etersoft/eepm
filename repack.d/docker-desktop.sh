#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_electron_deps

fix_chrome_sandbox

# conflicts with docker-buildx
remove_file /usr/lib/docker/cli-plugins/docker-buildx

add_requires /usr/bin/docker

ln -s usr/bin/docker usr/local/bin/com.docker.cli
pack_file /usr/local/bin/com.docker.cli

add_bin_link_command $PRODUCT /opt/docker-desktop/bin/docker-desktop
add_bin_link_command docker-index /opt/docker-desktop/bin/docker-index

#echo 'Enabling use of privileged ports by Docker Desktop'
#setcap cap_net_bind_service,cap_sys_resource=+ep /opt/docker-desktop/bin/com.docker.backend || echo 'Error: Docker Desktop will not be able to bind to privileged ports'

#systemctl start --user docker-desktop
