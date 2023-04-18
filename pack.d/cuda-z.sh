#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
PRODUCT="cuda-z"

. $(dirname $0)/common.sh

CURDIR="$(pwd)"

PKGDIR="$(mktemp -d)"
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

PKGNAME="$(basename $TAR .run | tr "[A-Z_]" "[a-z-]")"

install -D $TAR opt/$PRODUCT/$PRODUCT || fatal
erc pack $CURDIR/$PKGNAME.tar opt/$PRODUCT

return_tar $PKGNAME.tar
