#!/bin/sh
PKGNAME=waterfox
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Fast and Private Web Browser"
URL="https://www.waterfox.net/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
	VERSION="$(get_github_tag https://github.com/BrowserWorks/Waterfox/)"
fi

PKGURL="https://cdn1.waterfox.net/waterfox/releases/$VERSION/Linux_x86_64/waterfox-$VERSION.tar.bz2"

install_pack_pkgurl $VERSION
