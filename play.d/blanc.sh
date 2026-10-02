#!/bin/sh

PKGNAME=Blanc
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Blanc Browser from the official site'
URL="https://blancbrowser.com/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/bnfy/blanc" "Blanc-$VERSION.AppImage")
else
    PKGURL="https://github.com/bnfy/blanc/releases/download/v$VERSION/Blanc-$VERSION.AppImage"
fi

install_pkgurl
