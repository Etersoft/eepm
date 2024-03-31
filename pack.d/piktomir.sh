#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

# TODO: inform vendor
VERSION=0.1

PKGNAME="$PRODUCT-$VERSION.AppImage"

mv -v $TAR $PKGNAME

return_tar $PKGNAME
