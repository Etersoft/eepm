#!/bin/sh

PKGNAME=iptvnator
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='IPTV player from the official site'
URL="https://github.com/4gray/iptvnator"

. $(dirname $0)/common.sh

arch=$(epm print info -a)
case "$arch" in
    x86_64)
        arch=amd64
        ;;
    aarch64)
        arch=arm64
        ;;
esac

pkgtype=deb

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/4gray/iptvnator/" "$PKGNAME*.$VERSION*$arch.$pkgtype")
else
    PKGURL="https://github.com/4gray/iptvnator/releases/download/v$VERSION/${PKGNAME}_${VERSION}_$arch.$pkgtype"
fi

install_pkgurl
