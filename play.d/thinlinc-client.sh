#!/bin/sh

PKGNAME=thinlinc-client
SUPPORTEDARCHES="x86_64 x86 armhf"
VERSION="$2"
DESCRIPTION="ThinLinc Client from the official site"
URL="https://www.cendio.com/thinlinc"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] || VERSION="$VERSION-*"

pkgtype=$(epm print info -p)
arch="$(epm print info -a)"

case "$pkgtype-$arch" in
    rpm-x86_64)
        file="thinlinc-client-$VERSION.x86_64.rpm"
        ;;
    rpm-x86)
        file="thinlinc-client-$VERSION.i686.rpm"
        ;;
    rpm-armhf)
        file="thinlinc-client-$VERSION.armv7hl.rpm"
        ;;
    *-x86_64)
        file="thinlinc-client_${VERSION}_amd64.deb"
        ;;
    *-x86)
        file="thinlinc-client_${VERSION}_i386.deb"
        ;;
    *-armhf)
        file="thinlinc-client_${VERSION}_armhf.deb"
        ;;
esac

PKGURL="https://www.cendio.com/downloads/clients/$file"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm install $repack "$PKGURL"
