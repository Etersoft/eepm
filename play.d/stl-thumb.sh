#!/bin/sh

PKGNAME=stl-thumb
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Fast lightweight thumbnail generator for 3D model files (STL, OBJ, 3MF)"
URL="https://github.com/unlimitedbacon/stl-thumb"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "${PKGNAME}_*_${arch}.deb")
else
    PKGURL="$URL/releases/download/v$VERSION/${PKGNAME}_${VERSION}_${arch}.deb"
fi

install_pkgurl
