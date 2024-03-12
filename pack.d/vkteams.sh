#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

if echo "$TAR" | grep -q "vkteams.tar.xz" ; then
    erc "$TAR" || fatal
else
    fatal "We support only vkteams.tar.xz"
fi

mkdir opt
mv vkteams* opt/$PRODUCT || fatal

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME opt/$PRODUCT

return_tar $PKGNAME
