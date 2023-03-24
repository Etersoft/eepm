#!/bin/sh

TAR="$1"
#VERSION="$2"
RETURNTARNAME="$2"
PRODUCT="$(basename $0 .sh)"

. $(dirname $0)/common.sh

CURDIR="$(pwd)"

PKGDIR="$(mktemp -d)"
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

erc $TAR || fatal

# use version from tarball
# (TODO: get basename via erc
PKGNAME="$(basename $TAR .tar.xz | sed -e "s|^tsetup|$PRODUCT|" )"
#PKGNAME="$(basename $PKGNAME .zip | )"

f=$PRODUCT
[ -f "$PRODUCT/$PRODUCT" ] && f="$PRODUCT/$PRODUCT"

mkdir -p opt/$PRODUCT || fatal
cp $f opt/$PRODUCT || fatal
erc pack $CURDIR/$PKGNAME.tar opt/$PRODUCT

return_tar $PKGNAME.tar
