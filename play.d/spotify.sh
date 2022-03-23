#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=spotify-client

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Spotify client for Linux from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# epm uses eget to download * names
epm install "https://repository-origin.spotify.com/pool/non-free/s/spotify-client/$(epm print constructname $PKGNAME "*" amd64 deb)"
