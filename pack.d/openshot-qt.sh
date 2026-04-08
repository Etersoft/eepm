#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# OpenShot-v3.5.1-x86_64.AppImage
VERSION="$(basename "$TAR" .AppImage | sed -e 's|OpenShot-v||' -e 's|-x86_64||')"
[ -n "$VERSION" ] || fatal "Can't extract version from $TAR file."

PKGNAME="$PRODUCT-$VERSION"

cp "$TAR" "$PKGNAME.AppImage" || fatal

return_tar "$PKGNAME.AppImage"
