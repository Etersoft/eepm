#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

# TODO: generalize these replacements
# ktalk2.10.0x86_64.AppImage
PKGNAME="$PRODUCT.AppImage"
mv -v $TAR $PKGNAME

return_tar $PKGNAME
