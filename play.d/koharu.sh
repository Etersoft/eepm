#!/bin/sh

PKGNAME=koharu
VERSION="$2"
SUPPORTEDARCHES="x86_64 aarch64"
DESCRIPTION='ML-powered manga translator'
URL="https://github.com/koharu-rs/koharu"

. $(dirname $0)/common.sh

arch=$(epm print info --debian-arch)
pkgtype=deb

if ! is_glibc_enough 2.39 ; then
    pkgtype=AppImage
    [ "$arch" = "arm64" ] && arch=aarch64
fi

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "koharu_${VERSION}_$arch.$pkgtype")
else
    PKGURL="$URL/releases/download/$VERSION/koharu_${VERSION}_$arch.$pkgtype"
fi

if [ "$pkgtype" = "AppImage" ] ; then
    install_pack_pkgurl
else
    install_pkgurl
fi
