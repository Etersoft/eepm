#!/bin/sh

PKGNAME=XnViewMP
DESCRIPTION="XnView MP: Image management from the official site"

. $(dirname $0)/common.sh


repack='--repack'
arch=$($DISTRVENDOR --distro-arch)
case $arch in
    x86_64|amd64)
        ;;
    *)
        fatal "Unsupported arch $arch for $($DISTRVENDOR -d)"
esac

epm install https://download.xnview.com/XnViewMP-linux-x64.deb
