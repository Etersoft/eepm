#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
FPRODUCT="Telegram"
TPRODUCT="Telegram"

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

f=$FPRODUCT
[ -f "$(echo */$FPRODUCT)" ] && f="$(echo */$FPRODUCT)"

mkdir -p opt/$TPRODUCT || fatal
cp $f opt/$TPRODUCT/$TPRODUCT || fatal
erc pack $CURDIR/$PKGNAME.tar opt/$TPRODUCT

return_tar $PKGNAME.tar
