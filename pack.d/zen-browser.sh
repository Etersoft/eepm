#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

# https://github.com/zen-browser/desktop/releases/download/1.10b/zen-x86_64.AppImage
VERSION=$(echo "$URL" | grep -oP 'download/\K[0-9]+\.[0-9a-e]+')
[ -n "$VERSION" ] || fatal "Can't get package version"

# rename package
PKGNAME="$PRODUCT-$VERSION.AppImage"

mv -v $TAR $PKGNAME

return_tar $PKGNAME
