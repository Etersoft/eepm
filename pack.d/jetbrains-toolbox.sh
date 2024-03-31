#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# use version from tarball
PKGNAME="$(basename $TAR .tar.gz)"

# they packed AppImage to tarball, so unpack it
erc $TAR || fatal
cd $PKGNAME* || fatal
cp $PRODUCT $PKGNAME.AppImage || fatal

return_tar $PKGNAME.AppImage
