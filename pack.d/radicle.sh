#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION=$3

. $(dirname $0)/common.sh

# radicle-x86_64-unknown-linux-musl.tar.gz
BASENAME=$(basename $TAR .tar.gz)

erc unpack $TAR || fatal
cd *

mkdir -p usr/share/man/man1
mkdir -p opt/$PRODUCT

mv man/man1/*.1 usr/share/man/man1/
mv bin/* opt/$PRODUCT/

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
