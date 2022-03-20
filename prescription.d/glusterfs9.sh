#!/bin/sh

[ "$1" != "--run" ] && echo "Install glusterfs9 (or upgrade from glusterfs8)" && exit

[ "$($DISTRVENDOR -d)" != "ALTLinux" ] && echo "Only ALTLinux is supported" && exit 1

GFSOLD=glusterfs8
GFSNEW=glusterfs9

if epmqp --quiet ${GFSOLD}- ; then
    # Upgrade if was installed
    epmi $(epmqp --short $GFSOLD | grep -v rdma | grep -v devel | sed -e "s|$GFSOLD|$GFSNEW|") ${GFSOLD}- ${GFSOLD}-client- python3-module-${GFSOLD}-
    epm installed $GFSNEW-server && serv glusterd on
else
    # Install all packages
    epmi ${GFSNEW}-cli ${GFSNEW}-client ${GFSNEW} || exit

    echo "You can install also '${GFSNEW}-server' if it is needed for this host"

    epme $(epmqp ${GFSOLD})
fi
