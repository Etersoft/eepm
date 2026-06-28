#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_electron_deps


# bundled cli-plugins conflict on files with the system docker-buildx/docker-compose packages
remove_file /usr/lib/docker/cli-plugins/docker-buildx
remove_file /usr/lib/docker/cli-plugins/docker-compose

# Docker Desktop runs its own engine in a qemu VM but drives it via the system docker CLI
add_requires /usr/bin/docker qemu-system-x86

mkdir -p usr/local/bin
ln -s usr/bin/docker usr/local/bin/com.docker.cli
pack_file /usr/local/bin/com.docker.cli

add_bin_link_command $PRODUCT /opt/docker-desktop/bin/docker-desktop
# docker-index binary was dropped in newer Docker Desktop (4.79), so no link for it

#echo 'Enabling use of privileged ports by Docker Desktop'
#setcap cap_net_bind_service,cap_sys_resource=+ep /opt/docker-desktop/bin/com.docker.backend || echo 'Error: Docker Desktop will not be able to bind to privileged ports'

#systemctl start --user docker-desktop
