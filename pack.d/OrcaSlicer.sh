#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# OrcaSlicer_Linux_V2.0.0.AppImage

VERSION="$(basename "$TAR" .AppImage| sed -e 's|OrcaSlicer_Linux_V||')"
[ -n "$VERSION" ] || fatal "Can't extract version from $TAR file."

PKGNAME=$PRODUCT-$VERSION

cp $TAR $PKGNAME.AppImage || fatal

return_tar $PKGNAME.AppImage
