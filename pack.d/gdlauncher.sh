#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# GDLauncher__2.0.24__linux__x64.AppImage 
VERSION=$(basename $TAR .AppImage | sed -e 's|GDLauncher__||' | sed -e 's|__linux__x64||')
PKGNAME="$PRODUCT-$VERSION.AppImage"

mv -v $TAR $PKGNAME

return_tar $PKGNAME
