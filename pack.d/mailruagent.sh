#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

if echo "$TAR" | grep -q "agent.tar.xz" ; then
    erc "$TAR" || fatal
else
    fatal "We support only agent.tar.xz"
fi

mkdir opt
mv agent.tar opt/$PRODUCT || fatal

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME opt/$PRODUCT

return_tar $PKGNAME
