#!/bin/sh

PKGNAME=q-spider
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='A player that allows you to run QSP games in your browser.'
URL="https://github.com/QSPFoundation/qspider/releases"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/QSPFoundation/qspider/" "${PKGNAME}_${VERSION}_amd64.AppImage")
else
    PKGURL="https://github.com/QSPFoundation/qspider/releases/download/v$VERSION/${PKGNAME}_${VERSION}_amd64.AppImage"
fi

install_pkgurl
