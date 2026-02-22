#!/bin/sh

PKGNAME=ShikiWatch
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Unofficial mobile and desktop application for Shikimori'
URL="https://github.com/wheremyfiji/ShikiWatch"

. $(dirname $0)/common.sh

arch=x64
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/wheremyfiji/ShikiWatch/" "${PKGNAME}-${VERSION}-linux-$arch.AppImage")
else
    PKGURL="https://github.com/wheremyfiji/ShikiWatch/releases/download/v$VERSION/${PKGNAME}-$VERSION-linux-$arch.AppImage"
fi

install_pkgurl
