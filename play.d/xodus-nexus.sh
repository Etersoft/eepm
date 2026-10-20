#!/bin/sh

PKGNAME=Xodus-Nexus
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Xbox-inspired Microsoft Store game launcher for Linux'
URL="https://github.com/domsvoboda/xodus-nexus"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "$PKGNAME-$VERSION-x86_64.AppImage")
else
    PKGURL="$URL/releases/download/v$VERSION/$PKGNAME-$VERSION-x86_64.AppImage"
fi

install_pkgurl
