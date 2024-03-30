#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

PRODUCT="snap4arduino"
# Snap4Arduino_desktop-gnu-64_9.1.1
PKGNAME="$(basename "$TAR" | sed -e "s|Snap4Arduino_desktop-gnu-[36][24]\_|$PRODUCT-|")"

mkdir opt/
erc $TAR
mv -v Snap4Arduino* opt/$PRODUCT

erc a $PKGNAME opt

return_tar $PKGNAME
