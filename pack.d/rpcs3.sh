#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# rpcs3-v0.0.21-13357-ff34a73f_linux64.AppImage

VERSION="$(basename "$TAR" | sed -e 's|^rpcs3-v||' -e 's|-.*||')"
[ -n "$VERSION" ] || fatal "Can't extract version from $TAR file."

PKGNAME=$PRODUCT-$VERSION

cp $TAR $PKGNAME.AppImage || fatal

return_tar $PKGNAME.AppImage
