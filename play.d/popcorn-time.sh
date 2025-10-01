#!/bin/sh

PKGNAME=popcorn-time-nightly
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Popcorn Time is a multi-platform, free software BitTorrent client that includes an integrated media player'
URL="https://github.com/popcorn-official/popcorn-desktop"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(eget -O- https://popcorntime.app/download  | grep -oP 'https://[^"]+\.deb' | head -n1)
else
    PKGREL=$(eget -O- https://popcorntime.app/download   | grep -oP 'nightly/[0-9\.]+-\K[0-9]+' | head -n1)
    PKGURL="https://get.popcorntime.app/nightly/$VERSION-$PKGREL/linux/x86_64/Popcorn_Time_Nightly_${VERSION}_amd64.deb"
fi

# repack always, ever for deb system (bad postinst script)
install_pkgurl --repack
