#!/bin/sh

PKGNAME=osu-lazer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="osu! lazer - a free-to-win rhythm game"
URL="https://github.com/ppy/osu"

. $(dirname $0)/common.sh

epm assure unsquashfs squashfs-tools || fatal

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "osu.AppImage")
else
    [ -n "$RELEASE" ] && VERSION="$VERSION-$RELEASE"
    PKGURL="$URL/releases/download/$VERSION/osu.AppImage"
fi

install_pack_pkgurl
