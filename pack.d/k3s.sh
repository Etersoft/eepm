#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

install -D $TAR usr/bin/$PRODUCT || fatal
for i in kubectl crictl ctr k3s ; do
    ln -sf $PRODUCT usr/bin/$i
done
erc pack $PKGNAME.tar usr/bin

return_tar $PKGNAME.tar
