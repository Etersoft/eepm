#!/bin/sh

PKGNAME=vinteo-screencast
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="VINTEO Screencast (content sharing to Vinteo videoconference) from the official site"
URL="https://vinteo.ru/download/vinteo-screencast/"

. $(dirname $0)/common.sh

BASEURL="https://download.vinteo.com/VinteoScreencast/linux"

if [ "$VERSION" = "*" ] ; then
    VERSION="$(fetch_url "$BASEURL/" | grep -o 'href="[0-9][0-9.]*/"' | sed -e 's|^href="||' -e 's|/"$||' | sort -V | tail -n1)"
    [ -n "$VERSION" ] || fatal "Can't get the latest version from $BASEURL"
fi

# altlinux/ and astra-linux/ subdirs contain the same files (only the build number differs)
# use rpm, but not for ALT
if [ "$(epm print info -p)" = "rpm" ] && [ "$(epm print info -s)" != "alt" ] ; then
    PKGURL="$BASEURL/$VERSION/vinteo-screencast-$VERSION-x86_64.rpm"
else
    PKGURL="$BASEURL/$VERSION/vinteo-screencast-$VERSION-amd64.deb"
fi

install_pkgurl
