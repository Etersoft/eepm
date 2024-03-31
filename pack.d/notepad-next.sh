#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh
# NotepadNext-v0.7-x86_64.AppImage

BASENAME=$(basename $TAR .AppImage)
VERSION=$(echo $BASENAME | sed -e 's|NotepadNext-v||' | sed -e 's|-x86_64||')

PKGNAME="$PRODUCT-$VERSION"

cp $TAR $PKGNAME.AppImage || fatal

return_tar $PKGNAME.AppImage