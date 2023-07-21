#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# pcsx2-v1.7.4767-linux-appimage-x64-Qt.AppImage

VERSION="$(basename "$TAR" | sed -e 's|^pcsx2-v||' -e 's|-.*||')"
[ -n "$VERSION" ] || fatal "Can't extract version from $TAR file."

PKGNAME=$PRODUCT-$VERSION

cp $TAR $PKGNAME.AppImage || fatal

return_tar $PKGNAME.AppImage
