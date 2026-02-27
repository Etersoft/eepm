#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# Bambu_Studio_linux_fedora-v02.05.00.66.AppImage
# Bambu_Studio_ubuntu-24.04_PR-9540.AppImage

VERSION="$(basename "$TAR" .AppImage | sed -e 's|Bambu_Studio_linux_fedora-v||' -e 's|Bambu_Studio_ubuntu-[0-9.]*_PR-||')"
[ -n "$VERSION" ] || fatal "Can't extract version from $TAR file."

PKGNAME=$PRODUCT-$VERSION

cp $TAR $PKGNAME.AppImage || fatal

return_tar $PKGNAME.AppImage
