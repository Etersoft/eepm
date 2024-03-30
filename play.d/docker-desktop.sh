#!/bin/sh

PKGNAME=docker-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Docker Desktop from the official site"
URL="https://docs.docker.com/desktop/install/ubuntu/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGURL="https://desktop.docker.com/linux/main/amd64/139021/docker-desktop-4.28.0-x86_64.rpm"
        ;;
    deb)
        PKGURL="https://desktop.docker.com/linux/main/amd64/139021/docker-desktop-4.28.0-amd64.deb"
        ;;
esac

repack=''
if [ "$(epm print info -s)" = "alt" ] ; then
    PKGURL="https://desktop.docker.com/linux/main/amd64/139021/docker-desktop-4.28.0-amd64.deb"
    repack='--repack'
fi

epm install $repack "$PKGURL"
