#!/bin/sh
PKGNAME=firefox
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Fast and Private Web Browser"
URL="https://www.mozilla.org/en-US/firefox"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
	VERSION="$(eget -O- https://www.mozilla.org/en-US/firefox/releases/ | grep -oP '\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n1)"
fi

arch=$(epm print info -a)

if [ "$(epm print compare "$VERSION" 136.0)" != "-1" ] ; then
    ext="tar.xz"
else
    ext="tar.bz2"
fi

PKGURL="https://ftp.mozilla.org/pub/firefox/releases/$VERSION/linux-$arch/en-US/firefox-$VERSION.$ext"

install_pack_pkgurl $VERSION
