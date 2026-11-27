#!/bin/sh

PKGNAME=rms-viewer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="RMS Remote Access viewer (Remote Manipulator System client) from the official site"
URL="https://rmansys.ru/files/linux/"

. $(dirname $0)/common.sh

# https://rmansys.ru/download/qt/linux/rms-viewer-2.1.2-1.x86_64.rpm
if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest "$URL" "$PKGNAME-*.x86_64.rpm")"
else
    [ -n "$RELEASE" ] && [ "$RELEASE" != "*" ] || RELEASE="1"
    PKGURL="https://rmansys.ru/download/qt/linux/$PKGNAME-$VERSION-$RELEASE.x86_64.rpm"
fi

install_pkgurl
