#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar

erc unpack $TAR
cd * || fatal

mkdir -p usr/bin/
mv flashplayer usr/bin/
mkdir -p usr/share/doc/flashplayer/
mv LGPL license.pdf usr/share/doc/flashplayer/

erc pack $PKGNAME usr/bin/flashplayer usr/share/doc/flashplayer

return_tar $PKGNAME
