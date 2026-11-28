#!/bin/sh

PKGNAME=dion
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='DION - video conferencing and corporate communications from the official site'
URL="https://dion.vc/"

. $(dirname $0)/common.sh

BASEURL="https://static.dion.vc/desktop_app"

if [ "$VERSION" = "*" ] ; then
    VERSION="$(fetch_url "$BASEURL/latest-linux.yml" | awk '/^version:/{print $2; exit}' | tr -d '\r')"
    [ -n "$VERSION" ] || fatal "Can't get latest version."
fi

# https://static.dion.vc/desktop_app/dion-5.34.2.x86_64.rpm
PKGURL="$BASEURL/$PKGNAME-$VERSION.x86_64.rpm"

install_pkgurl
