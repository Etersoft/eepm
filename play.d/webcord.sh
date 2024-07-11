#!/bin/sh

PKGNAME=WebCord
SUPPORTEDARCHES="x86_64 arm64"
VERSION="$2"
DESCRIPTION="A Discord and Spacebar client implemented directly without Discord API from the official github"
URL="https://github.com/SpacingBat3/WebCord"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=x64
        ;;
    aarch64)
        arch=arm64
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac


pkgtype=AppImage
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/SpacingBat3/WebCord/" "WebCord-.$VERSION-$arch.$pkgtype")
else
    PKGURL="https://github.com/SpacingBat3/WebCord/releases/download/v$VERSION/WebCord-$VERSION-$arch.$pkgtype"
fi

install_pkgurl
