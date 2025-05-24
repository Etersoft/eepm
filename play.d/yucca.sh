#!/bin/sh

PKGNAME=yucca
SUPPORTEDARCHES="x86_64 armhf aarch64"
VERSION="$2"
DESCRIPTION="Simple solution for video surveillance"
URL="https://yucca.app/"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"
case "$arch" in
    armv7l)
        arch=arm ;;
esac

if [ "$VERSION" = "*" ] ; then
    VERSION="$(eget -O- https://releases.yucca.app/latest/VERSION.txt)"
fi

PKGURL="https://releases.yucca.app/v${VERSION}/yucca_${VERSION}_linux_${arch}.tar.gz"

install_pack_pkgurl $VERSION
