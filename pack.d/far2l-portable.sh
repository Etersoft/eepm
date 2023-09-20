#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
# PRODUCT="far2l"

. $(dirname $0)/common.sh

erc $TAR || fatal
PKGNAME="$(ls | grep -e "_x86_64.AppImage$")"
return_tar "$PKGNAME"

# TODO: return original version from generic-appimage.sh
# VERSION="$(basename "$PKGNAME" .AppImage | awk -F_ '{print $2}')"
# [ -n "$VERSION" ] || fatal "Can't get version $TAR."
# mv "$PKGNAME" "$PRODUCT-$VERSION.AppImage"
# return_tar "$PRODUCT-$VERSION.AppImage"
