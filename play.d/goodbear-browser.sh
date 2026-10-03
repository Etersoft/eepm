#!/bin/sh

PKGNAME=goodbear-browser
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Good Bear - Firefox based browser with Russian Ministry of Digital Development certificates support"
URL="https://github.com/Goudron/good-bear"

. $(dirname $0)/common.sh

# deb version is 1.0+firefox156.0, but GitHub release asset is URL-encoded (%2B), so match by base version only
if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "goodbear-browser_*_amd64.deb")"
else
    PKGURL="$(get_github_url "$URL" "goodbear-browser_${VERSION%%+*}*_amd64.deb")"
fi

install_pkgurl
