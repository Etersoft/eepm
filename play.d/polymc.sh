#!/bin/sh

PKGNAME=PolyMC-Linux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Minecraft launcher with the ability to manage multiple instances'
URL="https://github.com/PolyMC/PolyMC"

. $(dirname $0)/common.sh

arch=x86_64
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/PolyMC/PolyMC/" "PolyMC-Linux-${VERSION}-${arch}.AppImage")
else
    PKGURL="https://github.com/PolyMC/PolyMC/releases/download/$VERSION/PolyMC-Linux-${VERSION}-${arch}.AppImage"
fi

install_pkgurl
