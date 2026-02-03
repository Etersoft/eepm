#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
PRODUCT=karing

. $(dirname $0)/common.sh

# Form package name with correct version
PKGNAME="$PRODUCT-$VERSION.$(basename $TAR | sed 's/.*\.//')"

# Copy source package with new name preserving original extension
cp $TAR $PKGNAME || fatal

return_tar $PKGNAME