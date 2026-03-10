#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

erc --here unpack "$TAR" || fatal

SRCDIR="$(erc basename "$TAR")"
SPELLCHECK_DIR="$SRCDIR/spellcheck"

DEST="opt/kingsoft/wps-office/office6/dicts/spellcheck"
mkdir -p "$DEST" || fatal
cp -a "$SPELLCHECK_DIR"/. "$DEST"/ || fatal

erc pack $PKGNAME.tar opt || fatal

return_tar $PKGNAME.tar
