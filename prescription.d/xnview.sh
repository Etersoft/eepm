#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=XnViewMP

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "XnView MP: Image management from the official site" && exit

repack='--repack'
arch=$($DISTRVENDOR --distro-arch)
case $arch in
    x86_64|amd64)
        ;;
    *)
        fatal "Unsupported arch $arch for $($DISTRVENDOR -d)"
esac

epm install https://download.xnview.com/XnViewMP-linux-x64.deb
