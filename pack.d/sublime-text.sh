#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

PRODUCT=sublime-text
PKGNAME="$(basename "$TAR" | sed -e "s|sublime_text_build_|$PRODUCT-|" -e 's|_.*||' )"

mkdir opt/
erc $TAR
mv -v sublime* opt/$PRODUCT

erc a $PKGNAME.tar opt

return_tar $PKGNAME.tar
