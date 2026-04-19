#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

erc --here unpack "$TAR" || fatal

SRCDIR="$(erc basename "$TAR")"

FONTDIR="usr/share/fonts/wps-fonts"
mkdir -p "$FONTDIR" || fatal
install -m644 "$SRCDIR"/*.ttf "$FONTDIR"/ || fatal

erc pack $PKGNAME.tar usr || fatal

return_tar $PKGNAME.tar
