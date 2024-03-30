#!/bin/sh

PKGNAME=meridius
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Meridius — music player for VK"
URL="https://github.com/PurpleHorrorRus/Meridius"

. $(dirname $0)/common.sh

if [ "$VERSION" != "*" ] ; then
    PKGURL="https://github.com/PurpleHorrorRus/Meridius/releases/download/v$VERSION/meridius-$VERSION.tar.gz"
else
    PKGURL=$(eget --list --latest https://github.com/PurpleHorrorRus/Meridius/releases "$PKGNAME-*.tar.gz") || fatal "Can't get package URL"
fi

epm install "$PKGURL"
