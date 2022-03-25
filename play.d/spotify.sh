#!/bin/sh

PKGNAME=spotify-client
DESCRIPTION="Spotify client for Linux from the official site"

. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# epm uses eget to download * names
epm install "https://repository-origin.spotify.com/pool/non-free/s/spotify-client/$(epm print constructname $PKGNAME "*" amd64 deb)"
