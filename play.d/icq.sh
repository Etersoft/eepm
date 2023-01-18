#!/bin/sh

PKGNAME=icq
SUPPORTEDARCHES="x86_64"
DESCRIPTION="ICQ for Linux from the official site"

. $(dirname $0)/common.sh

# TODO:
# $ curl -H Snap-Device-Series:16 https://api.snapcraft.io/v2/snaps/info/icq-im
VERSION="10.0" #10.0.11121

PKGURL="https://icq-www.hb.bizmrg.com/linux/x64/icq.tar.xz"
PKGFILE="/tmp/$PKGNAME-$VERSION.tar.xz"

epm tool eget -O $PKGFILE $PKGURL || exit

epm install --repack "$PKGFILE" || exit
