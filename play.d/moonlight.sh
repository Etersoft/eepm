#!/bin/sh

PKGNAME=Moonlight
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="GameStream client for PCs (Windows, Mac, and Linux)"
URL="https://moonlight-stream.org/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/moonlight-stream/moonlight-qt/" "$PKGNAME-.$VERSION-x86_64.AppImage")
else
    PKGURL="https://github.com/moonlight-stream/moonlight-qt/releases/download/v$VERSION/$PKGNAME-$VERSION-x86_64.AppImage"
fi

install_pkgurl
