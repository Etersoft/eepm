#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

# ArmorPaint_10alpha_linux64.zip
erc unpack $TAR || fatal

mkdir -p opt/$PRODUCT

cp -a ArmorPaint*/* opt/$PRODUCT/

VERSION=$(basename $TAR | sed -e 's/_linux64.*//' -e 's/.*_//')
PKGNAME=$PRODUCT-$VERSION
erc pack $PKGNAME.tar opt || fatal

return_tar $PKGNAME.tar
