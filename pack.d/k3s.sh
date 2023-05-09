#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

install -D $TAR usr/bin/$PRODUCT || fatal
ln -s $PRODUCT usr/bin/kubectl
erc pack $PKGNAME.tar usr/bin/$PRODUCT usr/bin/kubectl

return_tar $PKGNAME.tar
