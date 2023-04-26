#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

PKGNAME="$(basename $TAR .run | tr "[A-Z_]" "[a-z-]")"

install -D $TAR opt/$PRODUCT/$PRODUCT || fatal
erc pack $PKGNAME.tar opt/$PRODUCT

return_tar $PKGNAME.tar
