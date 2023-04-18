#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
PRODUCT="$(basename $0 .sh)"
FPRODUCT="Telegram"

. $(dirname $0)/common.sh

CURDIR="$(pwd)"

PKGDIR="$(mktemp -d)"
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

erc $TAR || fatal

# use version from tarball
# (TODO: get basename via erc
PKGNAME="$(basename $TAR .zip | sed -e "s|_linux||" )"

f=$FPRODUCT
[ -f "$(echo */$FPRODUCT)" ] && f="$(echo */$FPRODUCT)"

mkdir -p opt/$PRODUCT || fatal
cp $f opt/$PRODUCT/$PRODUCT || fatal
erc pack $CURDIR/$PKGNAME.tar opt/$PRODUCT

return_tar $PKGNAME.tar
