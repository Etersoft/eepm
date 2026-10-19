#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# OrcaSlicer_Linux_AppImage_Ubuntu2404_V2.4.2.AppImage
# OrcaSlicer_Linux_AppImage_Ubuntu2404_aarch64_V2.4.2.AppImage
# OrcaSlicer_Linux_V2.2.0.AppImage (old releases)
VERSION="$(basename "$TAR" .AppImage | sed -e 's|^OrcaSlicer_Linux_.*V||')"
[ -n "$VERSION" ] || fatal "Can't extract version from $TAR file."

PKGNAME=$PRODUCT-$VERSION

cp $TAR $PKGNAME.AppImage || fatal

return_tar $PKGNAME.AppImage
