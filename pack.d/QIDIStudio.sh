#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# QIDIStudio_v02.07.02.60_Ubuntu24.AppImage -> 2.07.02.60 (as in the release tag)
VERSION="$(basename "$TAR" .AppImage | sed -e 's|^QIDIStudio_v0*||' -e 's|_Ubuntu[0-9]*$||')"
[ -n "$VERSION" ] || fatal "Can't extract version from $TAR file."

PKGNAME=$PRODUCT-$VERSION

cp $TAR $PKGNAME.AppImage || fatal

return_tar $PKGNAME.AppImage
