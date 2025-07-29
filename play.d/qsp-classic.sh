#!/bin/sh

PKGNAME=QSP_Classic
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Classic QSP player'
URL="https://github.com/QSPFoundation/qspgui/releases"

. $(dirname $0)/common.sh

arch=x86_64
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/QSPFoundation/qspgui/" "${PKGNAME}-v${VERSION}-$arch.AppImage")
else
    PKGURL="https://github.com/QSPFoundation/qspgui/releases/download/v$VERSION/${PKGNAME}-v${VERSION}-$arch.AppImage"
fi

install_pkgurl
