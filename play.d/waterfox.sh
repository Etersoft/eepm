#!/bin/sh
PKGNAME=waterfox
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Fast and Private Web Browser"
URL="https://www.waterfox.net/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
	VERSION="$(curl -s https://api.github.com/repos/BrowserWorks/Waterfox/releases/latest | grep -oP '"tag_name": "\K(.*?)(?=")' | sed 's/G//g')"
fi

PKGURL="https://cdn1.waterfox.net/waterfox/releases/G$VERSION/Linux_x86_64/waterfox-G$VERSION.tar.bz2"

install_pack_pkgurl $VERSION
