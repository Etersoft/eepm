#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

# NotepadNext-v0.13-x86_64.AppImage -> NotepadNext-0.13.AppImage
[ -n "$VERSION" ] || VERSION=$(echo "$TAR" | grep -oP 'v\K[0-9]+\.[0-9.]+')
[ -n "$VERSION" ] || fatal "Can't get version"

PKGNAME=$PRODUCT-$VERSION.AppImage

cp $TAR $PKGNAME || fatal

return_tar $PKGNAME
