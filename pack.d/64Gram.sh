#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
FPRODUCT="Telegram"

. $(dirname $0)/common.sh

erc $TAR || fatal

# use version from tarball
# (TODO: get basename via erc
PKGNAME="$(basename $TAR .zip | sed -e "s|_linux||" )"

f=$FPRODUCT
[ -f "$(echo */$FPRODUCT)" ] && f="$(echo */$FPRODUCT)"

install -D -m755 $f opt/$PRODUCT/$PRODUCT || fatal
erc pack $PKGNAME.tar opt/$PRODUCT

return_tar $PKGNAME.tar
