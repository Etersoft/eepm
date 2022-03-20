#!/bin/sh

[ "$1" != "--run" ] && echo "Install glusterfs7 (or upgrade from glusterfs6)" && exit

[ "$($DISTRVENDOR -d)" != "ALTLinux" ] && echo "Only ALTLinux is supported" && exit 1

if epmqp --quiet glusterfs6- ; then
    # Upgrade if was installed
    epmi $(epmqp --short glusterfs6 | sed -e "s|fs6|fs7|") glusterfs6- glusterfs6-client- python3-module-glusterfs6-
    epm installed glusterfs7-server && serv glusterd on
else
    # Install all packages
    epmi glusterfs7-client glusterfs7 || exit

    echo "You can install also 'glusterfs7-server' if it is needed for this host"

    epme $(epmqp glusterfs6)
fi
