#!/bin/sh

PKGNAME=zoom
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="Zoom client from the official site"
URL="https://zoom.us"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION="latest"

arch=$(epm print info --distro-arch)
case $arch in
    x86_64|amd64)
        arch=$arch ;;
    i586|i386)
        # latest does not work
        VERSION=5.4.53391.1108
        arch=i686 ;;
    *)
        fatal "Unsupported arch $arch for $(epm print info -d)"
esac

repack=''
[ "$(epm print info -s)" = "alt" ] && repack="--repack"

# TODO: there are more complex distro dependent url
epm install $repack "https://zoom.us/client/$VERSION/zoom_$arch.$(epm print info -p)"
