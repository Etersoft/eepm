#!/bin/sh

[ "$1" != "--run" ] && echo "Install glusterfs8 (or upgrade from glusterfs7)" && exit

[ "$($DISTRVENDOR -d)" != "ALTLinux" ] && echo "Only ALTLinux is supported" && exit 1

GFSOLD=glusterfs7
GFSNEW=glusterfs8

if epmqp --quiet ${GFSOLD}- ; then
    # Upgrade if was installed
    epmi $(epmqp --short $GFSOLD | grep -v rdma | sed -e "s|$GFSOLD|$GFSNEW|") ${GFSOLD}- ${GFSOLD}-client- python3-module-${GFSOLD}-
    epm installed $GFSNEW-server && serv glusterd on
else
    # Install all packages
    epmi ${GFSNEW}-cli ${GFSNEW}-client ${GFSNEW} || exit

    echo "You can install also '${GFSNEW}-server' if it is needed for this host"

    epme $(epmqp ${GFSOLD})
fi
