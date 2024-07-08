#!/bin/sh

PKGNAME=Popcorn-Time
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Popcorn Time is a multi-platform, free software BitTorrent client that includes an integrated media player'
URL="https://github.com/popcorn-official/popcorn-desktop"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/popcorn-official/popcorn-desktop/" "Popcorn-Time-.$VERSION-amd64.deb")
else
    PKGURL="https://github.com/popcorn-official/popcorn-desktop/releases/download/v$VERSION/Popcorn-Time-$VERSION-amd64.deb"
fi

# repack always, ever for deb system (bad postinst script)
install_pkgurl --repack
