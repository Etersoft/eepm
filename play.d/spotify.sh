#!/bin/sh

PKGNAME=spotify-client
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Spotify client for Linux from the official site"
URL="https://spotify.com"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="https://repository-origin.spotify.com/pool/non-free/s/spotify-client/$(epm print constructname $PKGNAME "*" amd64 deb)"
else
    PKGURL="https://repository-origin.spotify.com/pool/non-free/s/spotify-client/$(epm print constructname $PKGNAME "$VERSION" amd64 deb)"
fi

install_pkgurl
