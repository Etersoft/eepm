#!/bin/sh

PKGNAME=meridius
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Meridius — music player for VK"

. $(dirname $0)/common.sh

VERSION="$2"

if [ -n "$VERSION" ] ; then
    URL="https://github.com/PurpleHorrorRus/Meridius/releases/download/v$VERSION/meridius-$VERSION.tar.gz"
else
    URL=$(epm tool eget --list --latest https://github.com/PurpleHorrorRus/Meridius/releases "$PKGNAME-*.tar.gz") || fatal "Can't get package URL"
fi

epm install "$URL"
