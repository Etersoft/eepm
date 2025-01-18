#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# yandex-disk-indicator-1.12.2.tar.gz
BASENAME=$(basename $TAR .tar.gz)
VERSION=$(echo "$BASENAME" | sed -e 's|^yandex-disk-indicator-||')

erc unpack $TAR || fatal

cd * || fatal

export TARGET="usr"
mkdir "usr"
cd build
chmod +x prepare.sh
sh prepare.sh

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr || fatal

return_tar $PKGNAME.tar
