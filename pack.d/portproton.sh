#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || fatal "Missed archive version"

PKGNAME=$PRODUCT-$VERSION.tar

erc repack "$TAR" "$PKGNAME" || fatal

return_tar "$PKGNAME"

