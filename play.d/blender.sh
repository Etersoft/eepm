#!/bin/sh

PKGNAME=blender
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A fully integrated 3D graphics creation suite"
URL="https://blender.org"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ]; then
    VERSION="$(snap_get_version $PKGNAME)"
fi

PKGURL="https://download.blender.org/release/Blender${VERSION:0:3}/blender-${VERSION}-linux-x64.tar.xz"

install_pack_pkgurl
