#!/bin/sh

PKGNAME=credo-viewer
VERSION="$2"
RELEASE="$3"
SUPPORTEDARCHES="x86_64"
DESCRIPTION="TIM CREDO VIEWER (free viewer for CREDO projects) from the official site"
URL="https://credo-dialogue.ru/produkty/tim-kredo-viewer.html"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://credo-dialogue.ru/tsentr-zagruzki/programmy-dla-skachivania.html "$PKGNAME-*.x86_64.rpm")"
else
    # the server forbids listing, all known packages have release 1
    [ "$RELEASE" = "*" ] && RELEASE="1"
    PKGURL="https://download.credo-dialogue.ru/Products/$PKGNAME-$VERSION-$RELEASE.x86_64.rpm"
fi

install_pkgurl
