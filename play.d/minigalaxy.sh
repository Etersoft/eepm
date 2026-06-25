#!/bin/sh

PKGNAME=minigalaxy
SUPPORTEDARCHES="noarch"
VERSION="$2"
DESCRIPTION="Simple GOG Linux client"
URL="https://github.com/sharkwouter/minigalaxy"

. $(dirname $0)/common.sh

mask="minigalaxy_${VERSION}_all.deb"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/sharkwouter/minigalaxy" "$mask")
else
    PKGURL="https://github.com/sharkwouter/minigalaxy/releases/download/${VERSION}/$mask"
fi

install_pkgurl
