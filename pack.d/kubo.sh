#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

CURDIR="$(pwd)"

PKGDIR="$(mktemp -d)"
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

erc unpack $TAR && cd kubo || fatal
mkdir -p usr/bin
mv ipfs usr/bin
rm -v install.sh README.md
mkdir -p usr/share/doc/$PRODUCT
mv LICENSE* usr/share/doc/$PRODUCT

VERSION="$(echo "$TAR" | sed -e 's|.*kubo_v||' -e 's|[-_].*||')"
PKGNAME=$PRODUCT-$VERSION

erc pack $CURDIR/$PKGNAME.tar usr || fatal

return_tar $PKGNAME.tar
