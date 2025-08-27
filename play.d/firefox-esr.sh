#!/bin/sh
PKGNAME=firefox-esr
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Firefox ESR - Fast and Private Web Browser"
URL="https://www.mozilla.org/en-US/firefox"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
	VERSION="$(eget -O- https://ftp.mozilla.org/pub/firefox/releases/ | grep -oP '/releases/\K[0-9]+\.[0-9]+\.[0-9]+esr' | sort -V | tail -n1)"
fi

arch=$(epm print info -a)

if [ "$(epm print compare "$VERSION" 136.0)" != "-1" ] ; then
    ext="tar.xz"
else
    ext="tar.bz2"
fi

PKGURL="https://ftp.mozilla.org/pub/firefox/releases/$VERSION/linux-$arch/en-US/firefox-$VERSION.$ext"

install_pack_pkgurl $VERSION
