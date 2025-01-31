#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

mkdir -p usr/lib64/
mv -v $TAR usr/lib64/

erc pack $PKGNAME.tar usr

return_tar $PKGNAME.tar
