#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

CURDIR="$(pwd)"

PKGDIR="$(mktemp -d)"
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

# use version from tarball
PKGNAME="$(basename $TAR .tar.gz)"

erc $TAR || fatal
cd $PKGNAME || fatal
cp $PRODUCT $CURDIR/$PKGNAME.AppImage || fatal

return_tar $PKGNAME.AppImage
