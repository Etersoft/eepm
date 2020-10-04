#!/bin/sh

[ "$1" != "--run" ] && echo "Install glusterfs8 (or upgrade from glusterfs7)" && exit

[ "$(distro_info -d" != "ALTLinux" ] && echo "Only ALTLinux is supported" && exit 1

GFSOLD=glusterfs7
GFSNEW=glusterfs8

if epmqp --quiet ${GFSOLD}- ; then
    # Upgrade if was installed
    epmi $(epmqp --short $GFSOLD | grep -v rdma | sed -e "s|$GFSOLD|$GFSNEW|") ${GFSOLD}- ${GFSOLD}-client- python3-module-${GFSOLD}-
else
    # Install all packages
    epmi ${GFSNEW}-cli ${GFSNEW}-client ${GFSNEW}

    echo "You can install also '${GFSNEW}-server' if needed for this host"

    epme $(epmqp ${GFSOLD})
fi
