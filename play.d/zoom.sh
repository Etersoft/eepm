#!/bin/sh

PKGNAME=zoom
SUPPORTEDARCHES="x86_64 x86"
DESCRIPTION="Zoom client from the official site"

. $(dirname $0)/common.sh


arch=$($DISTRVENDOR --distro-arch)
case $arch in
    x86_64|amd64)
        version=latest
        arch=$arch ;;
    i586|i386)
        # latest does not work
        version=5.4.53391.1108
        arch=i686 ;;
    *)
        fatal "Unsupported arch $arch for $($DISTRVENDOR -d)"
esac

if [ "$($DISTRVENDOR -s)" = "alt" ] ; then
    epm install --repack https://zoom.us/client/$version/zoom_$arch.rpm
    exit
fi

# TODO: there are more complex distro dependent url
epm install "https://zoom.us/client/latest/zoom_$arch.$($DISTRVENDOR -p)"
