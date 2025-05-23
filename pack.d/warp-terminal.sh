#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

if [ -z "$VERSION" ] ; then
    # https://releases.warp.dev/stable/v0.2025.05.21.08.11.stable_01/Warp-x86_64.AppImage
    VERSION="$(basename "$(dirname "$URL")" | sed -e "s|^v||" -e "s|\.stable.*||")"
    [ -n "$VERSION" ] || fatal "Can't get package version"
fi

# rename package
PKGNAME="$PRODUCT-$VERSION.AppImage"

mv -v $TAR $PKGNAME

return_tar $PKGNAME
