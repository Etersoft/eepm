#!/bin/sh

PKGNAME=rats-search
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='A BitTorrent search program for desktop and web'
URL="https://github.com/DEgITx/rats-search/"

. $(dirname $0)/common.sh

arch=x86_64
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/DEgITx/rats-search/" "${PKGNAME}-${VERSION}-$arch.AppImage")
else
    PKGURL="https://github.com/DEgITx/rats-search/releases/download/v$VERSION/${PKGNAME}-${VERSION}-$arch.AppImage"
fi

install_pkgurl
