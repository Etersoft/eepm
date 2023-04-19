#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

CURDIR="$(pwd)"

PKGDIR="$(mktemp -d)"
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

erc $TAR || fatal

cp -v $PRODUCT*/pkg/aksusbd-*.x86_64.rpm $CURDIR || fatal

return_tar $CURDIR/$PRODUCT*.rpm
