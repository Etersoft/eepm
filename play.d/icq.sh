#!/bin/sh

PKGNAME=icq
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="ICQ for Linux from the official site"
URL="https://icq.com/desktop/ru?#linux"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- -H Snap-Device-Series:16 https://api.snapcraft.io/v2/snaps/info/icq-im | epm --inscript tool json -b | grep version | head -n1 | sed -e 's|.*"\([0-9.]*\)".*|\1|') || fatal "Can't get current version" #'
    #VERSION="10.0.16100"
fi

# TODO: install from snap
#PKGURL="https://icq-www.hb.bizmrg.com/linux/x64/icq.tar.xz"
PKGURL="https://hb.bizmrg.com/icq-www/linux/x64/packages/$VERSION/icq-${VERSION}_64bit.tar.xz"
epm install --repack "$PKGURL"
