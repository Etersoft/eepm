#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

VERSION="$(date -r "$TAR" "+%Y.%m.%d")"

PKGNAME="$PRODUCT-$VERSION"

cp $TAR $PKGNAME.AppImage || fatal

return_tar $PKGNAME.AppImage
